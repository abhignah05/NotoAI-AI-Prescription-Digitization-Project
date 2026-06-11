import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'dart:convert';
import 'home_screen.dart';

class PreviewScreen extends StatefulWidget {
  const PreviewScreen({super.key});

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  bool _loading = false;
  Map<String, dynamic>? _emrResult;
  String? _error;

  Future<void> _convertToEMR(String? imagePath, String? imageUrl) async {
    setState(() {
      _loading = true;
      _error = null;
      _emrResult = null;
    });
    try {
         var uri = Uri.parse('http://192.168.0.110:5000/upload');
      var request = http.MultipartRequest('POST', uri);
      if (kIsWeb && imageUrl != null) {
        // On web, fetch the image as bytes and upload
        final response = await http.get(Uri.parse(imageUrl));
        final bytes = response.bodyBytes;
        request.files.add(http.MultipartFile.fromBytes('image', bytes, filename: 'web_image.jpg'));
      } else if (imagePath != null) {
        request.files.add(await http.MultipartFile.fromPath('image', imagePath, filename: path.basename(imagePath)));
      } else {
        setState(() {
          _error = 'No image selected.';
        });
        return;
      }
      var response = await request.send();
      if (response.statusCode == 200) {
        var respStr = await response.stream.bytesToString();
        setState(() {
          _emrResult = json.decode(respStr);
        });
        // Show snackbar alert
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Stored!'), duration: Duration(seconds: 2)),
          );
        }
      } else {
        setState(() {
          _error = 'Failed to process image. (${response.statusCode})';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Object? arg = ModalRoute.of(context)?.settings.arguments;
    String? imagePath;
    String? imageUrl;
    if (kIsWeb) {
      imageUrl = arg as String?;
    } else {
      imagePath = arg as String?;
    }
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 60),
            const Text("PREVIEW", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Container(
              height: 300,
              margin: const EdgeInsets.all(20),
              color: Colors.grey[300],
              child: kIsWeb
                  ? (imageUrl != null
                      ? Image.network(imageUrl, fit: BoxFit.contain)
                      : const Center(child: Text("DOCUMENT")))
                  : (imagePath != null
                      ? Image.file(File(imagePath), fit: BoxFit.contain)
                      : const Center(child: Text("DOCUMENT"))),
            ),
            if (_loading) const CircularProgressIndicator(),
            if (_error != null) Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            ),
            if (_emrResult != null) ...[
              const SizedBox(height: 20),
              const Text('EMR Result', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Patient: ${_emrResult!['patientName'] ?? ''}'),
                    Text('Doctor: ${_emrResult!['doctorName'] ?? ''}'),
                    const SizedBox(height: 10),
                    const Text('Prescription:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(_emrResult!['emrData']?['prescription'] ?? ''),
                  ],
                ),
              ),
            ],
            if (!_loading && _emrResult == null && (imagePath != null || imageUrl != null))
              ElevatedButton(
                onPressed: () => _convertToEMR(imagePath, imageUrl),
                child: const Text("Convert to EMR"),
              ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
    );
  }
}
