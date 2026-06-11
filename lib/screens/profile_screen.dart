import 'package:flutter/material.dart';
import 'home_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final fields = [
      'Hospital Details',
      'Full Name',
      'Department',
      'License Number',
      'ID Number',
      'Specialisation',
    ];

    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 50),
          const CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
          const Text("USER DETAILS", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ...fields.map((label) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                child: ElevatedButton(
                  onPressed: () {},
                  child: Text(label),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.black,
                  ),
                ),
              )),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("LOG OUT"),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 3),
    );
  }
}
