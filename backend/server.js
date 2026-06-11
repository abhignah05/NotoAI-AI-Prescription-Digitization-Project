const express = require('express');
const mongoose = require('mongoose');
const multer = require('multer');
const cors = require('cors');
const dotenv = require('dotenv');
const Tesseract = require('tesseract.js');
const path = require('path');
const fs = require('fs');
const EMR = require('./models/emr');

dotenv.config();

const app = express();
app.use(cors());
app.use(express.json());

// Multer setup for file uploads
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, 'uploads/');
  },
  filename: function (req, file, cb) {
    cb(null, Date.now() + path.extname(file.originalname));
  },
});
const upload = multer({ storage });

// Connect to MongoDB
mongoose.connect(process.env.MONGO_URI, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});

// Helper: Convert OCR text to EMR JSON (improved parser)
function textToEMR(text) {
  // Extract patient name
  const patientMatch = text.match(/(?:Patient|Name)[:\s]+([A-Za-z .]+)/i);
  // Extract doctor name
  const doctorMatch = text.match(/(?:Dr\.?|Doctor)[:\s]+([A-Za-z .]+)/i);
  // Extract date
  const dateMatch = text.match(/Date[:\s]+([0-9\-\/]+)/i);
  // Extract medicines (lines starting with 'Syp', 'Tab', 'Cap', etc.)
  const medicineLines = text.split('\n').filter(line =>
    /^(Syp|Tab|Cap|Inj|Syrup|Tablet|Capsule|Injection)/i.test(line.trim())
  );
  // Fallback: all lines except those with patient/doctor/date
  const prescription = medicineLines.length
    ? medicineLines.join('\n')
    : text.split('\n').filter(line =>
        !/patient|doctor|date/i.test(line)
      ).join('\n');

  return {
    patientName: patientMatch ? patientMatch[1].trim() : '',
    doctorName: doctorMatch ? doctorMatch[1].trim() : '',
    date: dateMatch ? dateMatch[1].trim() : '',
    medicines: medicineLines,
    prescription,
  };
}

// POST /upload: Upload prescription, OCR, store EMR
app.post('/upload', upload.single('image'), async (req, res) => {
  try {
    const imagePath = req.file.path;
    const { data: { text } } = await Tesseract.recognize(imagePath, 'eng');
    const emrData = textToEMR(text);
    const emr = new EMR({
      patientName: emrData.patientName,
      doctorName: emrData.doctorName,
      prescriptionText: text,
      emrData,
    });
    await emr.save();
    // Optionally delete the image after processing
    fs.unlinkSync(imagePath);
    res.json(emr);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET /emrs: Get all EMRs
app.get('/emrs', async (req, res) => {
  try {
    const emrs = await EMR.find().sort({ createdAt: -1 });
    res.json(emrs);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`)); 