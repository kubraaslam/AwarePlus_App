import 'package:flutter/material.dart';

class QuizResultPage extends StatelessWidget {
  final int score;
  final int totalQuestions;

  const QuizResultPage({
    super.key,
    required this.score,
    required this.totalQuestions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Calculate percentage score for dynamic feedback
    final double percentage = (score / totalQuestions) * 100;
    String feedbackText;
    Color feedbackColor;

    if (percentage >= 80) {
      feedbackText = "Excellent!";
      feedbackColor = Colors.green.shade700;
    } else if (percentage >= 50) {
      feedbackText = "Good effort!";
      feedbackColor = Colors.orange.shade700;
    } else {
      feedbackText = "Keep trying!";
      feedbackColor = Colors.red.shade700;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Quiz Result"),
        backgroundColor: const Color.fromARGB(255, 209, 65, 113),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Trophy icon with a subtle shadow for depth
              Container(
                decoration: BoxDecoration(
                  color: Colors.pink.shade50,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromRGBO(233, 30, 99, 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: const Icon(
                  Icons.emoji_events,
                  size: 100,
                  color: Colors.pink,
                ),
              ),

              const SizedBox(height: 24),

              Text(
                'You scored',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.1,
                ),
              ),

              const SizedBox(height: 8),

              // Animated score text for subtle effect (can be expanded with animation controller)
              Text(
                '$score / $totalQuestions',
                style: theme.textTheme.displayMedium?.copyWith(
                  color: feedbackColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 56,
                  letterSpacing: 1.2,
                ),
              ),

              const SizedBox(height: 16),

              // Feedback text under the score
              Text(
                feedbackText,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: feedbackColor,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 50),

              SizedBox(
                width: 180,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/knowledge',
                    ); // Go back to topics
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 209, 65, 113),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 6,
                    shadowColor: Colors.pinkAccent,
                  ),
                  child: const Text(
                    'Back to Topics',
                    style: TextStyle(
                      fontSize: 18,
                      letterSpacing: 0.9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}