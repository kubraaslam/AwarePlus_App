import 'package:aware_plus/widgets/bottom_nav_bar.dart';
import 'package:flutter/material.dart';

class SupportView extends StatelessWidget {
  const SupportView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFC9184A),
        elevation: 0,
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
                border: Border.all(color: Colors.grey.shade500),
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
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/bookAppointment');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF758F),
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('Book Appointment'),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/myAppointments');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF758F), // Or any color you prefer
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('My Appointments'),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // External Helplines
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey.shade400)
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

            // Sexual Health Events
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey.shade400)
              ),
              elevation: 1,
              child: ListTile(
                title: const Text('Sexual Health Events'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                onTap: () {
                  Navigator.pushNamed(context, '/events');
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 2, // Index of Support tab
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/knowledge');
              break;
            case 2:
              // Stay on current
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/profile');
              break;
          }
        },
      ),
    );
  }
}
