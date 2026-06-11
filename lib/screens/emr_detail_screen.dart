import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class EMRDetailScreen extends StatelessWidget {
  final Map<String, dynamic> emr;
  const EMRDetailScreen({super.key, required this.emr});

  Future<pw.Document> _buildPdf() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Container(
          padding: const pw.EdgeInsets.all(24),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text('HOSPITAL NAME', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 24),
              pw.Text('Doctor: ${emr['doctorName'] ?? ''}'),
              pw.Text('Patient: ${emr['patientName'] ?? ''}'),
              pw.Text('Patient age: ${emr['emrData']?['age'] ?? ''}'),
              pw.Row(
                children: [
                  pw.Text('Problem: '),
                  pw.Text(emr['emrData']?['problem'] ?? ''),
                ],
              ),
              pw.SizedBox(height: 16),
              pw.Text('Prescriptions:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              if (emr['medicines'] != null && emr['medicines'].isNotEmpty)
                ...List<pw.Widget>.from((emr['medicines'] as List).map((med) => pw.Text('• $med'))),
              if (emr['prescription'] != null && (emr['medicines'] == null || emr['medicines'].isEmpty))
                pw.Text(emr['prescription']),
              pw.Spacer(),
              pw.SizedBox(height: 24),
              pw.Text('Signature:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
    return pdf;
  }

  Future<void> _exportPdf(BuildContext context) async {
    final pdf = await _buildPdf();
    await Printing.sharePdf(bytes: await pdf.save(), filename: 'emr.pdf');
  }

  Future<void> _printPdf(BuildContext context) async {
    final pdf = await _buildPdf();
    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EMR Detail'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Export as PDF',
            onPressed: () => _exportPdf(context),
          ),
          IconButton(
            icon: const Icon(Icons.print),
            tooltip: 'Print',
            onPressed: () => _printPdf(context),
          ),
        ],
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'HOSPITAL NAME',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 24),
              Text('Doctor: ${emr['doctorName'] ?? ''}'),
              Text('Patient: ${emr['patientName'] ?? ''}'),
              Text('Patient age: ${emr['emrData']?['age'] ?? ''}'),
              Row(
                children: [
                  const Text('Problem: '),
                  Text(emr['emrData']?['problem'] ?? ''),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Prescriptions:', style: TextStyle(fontWeight: FontWeight.bold)),
              if (emr['medicines'] != null && emr['medicines'].isNotEmpty)
                ...List<Widget>.from((emr['medicines'] as List).map((med) => Text('• $med'))),
              if (emr['prescription'] != null && (emr['medicines'] == null || emr['medicines'].isEmpty))
                Text(emr['prescription']),
              const Spacer(),
              const SizedBox(height: 24),
              const Text('Signature:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
} 