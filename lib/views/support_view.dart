import 'package:aware_plus/views/chat_view.dart';
import 'package:flutter/material.dart';

class SupportView extends StatelessWidget {
  const SupportView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFE7636E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Support Services',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Contact Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Need Help? Contact Us',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: const [
                      Icon(Icons.email_outlined, size: 30),
                      SizedBox(width: 12),
                      Text('SSS@apiit.lk'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => const ChatPage(
                                counselorId: 'SSS',
                              ), //should change w actual Id from firebase
                        ),
                      );
                    },
                    icon: const Icon(Icons.chat_bubble_outline),
                    label: const Text('Chat with SSS'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE7636E),
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      // Book appointment
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE7636E),
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Book an Appointment'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // External Helplines
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 1,
              child: ListTile(
                title: const Text('External Helplines'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                onTap: () {
                  Navigator.pushNamed(context, '/emergency');
                },
              ),
            ),

            const SizedBox(height: 10),

            // Clinic Locations
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 1,
              child: ListTile(
                title: const Text('Clinic Locations'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                onTap: () {
                  // Navigate
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
