import 'package:flutter/material.dart';

class QuizResultPage extends StatelessWidget {
  final int score;
  final int total;

  const QuizResultPage({super.key, required this.score, required this.total});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Score"),
        backgroundColor: Colors.pink[100],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "🎉 Quiz Completed!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              "You scored",
              style: TextStyle(fontSize: 18),
            ),
            Text(
              "$score / $total",
              style: TextStyle(fontSize: 32, color: Colors.pinkAccent, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                  Navigator.pushNamed(context, '/knowledge');
                },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text("Back to Topics"),
            )
          ],
        ),
      ),
    );
  }
}