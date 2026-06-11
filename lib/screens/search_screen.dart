import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'home_screen.dart';
import 'emr_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<dynamic> _emrs = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchEMRs();
  }

  Future<void> _fetchEMRs() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final response = await http.get(Uri.parse('http://192.168.0.110:5000/emrs'));
      if (response.statusCode == 200) {
        setState(() {
          _emrs = json.decode(response.body);
        });
      } else {
        setState(() {
          _error = 'Failed to fetch EMRs (${response.statusCode})';
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
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 50),
          const Padding(
            padding: EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search for patient details",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            ),
          if (!_loading && _emrs.isNotEmpty)
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: _emrs.length,
                itemBuilder: (context, index) {
                  final emr = _emrs[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EMRDetailScreen(emr: emr),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.person, size: 24, color: Colors.blueGrey),
                                const SizedBox(width: 8),
                                Text(
                                  emr['patientName']?.isNotEmpty == true ? emr['patientName'] : 'Unknown Patient',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                const Spacer(),
                                Text(
                                  emr['date'] ?? '',
                                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.medical_services, size: 20, color: Colors.teal),
                                const SizedBox(width: 6),
                                Text(
                                  emr['doctorName']?.isNotEmpty == true ? emr['doctorName'] : 'Unknown Doctor',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                            if (emr['medicines'] != null && emr['medicines'].isNotEmpty) ...[
                              const SizedBox(height: 10),
                              const Text('Medicines:', style: TextStyle(fontWeight: FontWeight.bold)),
                              ...List<Widget>.from((emr['medicines'] as List).map((med) => Text('• $med'))),
                            ],
                            const SizedBox(height: 10),
                            const Text('Prescription:', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(
                              emr['prescription'] != null && emr['prescription'].length > 120
                                ? emr['prescription'].substring(0, 120) + '...'
                                : (emr['prescription'] ?? ''),
                              style: const TextStyle(fontSize: 13, color: Colors.black87),
                            ),
                            const SizedBox(height: 10),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EMRDetailScreen(emr: emr),
                                    ),
                                  );
                                },
                                child: const Text('View'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          if (!_loading && _emrs.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text('No EMRs found.'),
            ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }
}
