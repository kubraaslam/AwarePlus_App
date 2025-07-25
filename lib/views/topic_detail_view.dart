import 'package:aware_plus/views/articles_view.dart';
import 'package:aware_plus/views/infographics_view.dart';
import 'package:aware_plus/views/quiz_levels_view.dart';
import 'package:flutter/material.dart';

class TopicDetailView extends StatelessWidget {
  final String topicTitle;

  const TopicDetailView({super.key, required this.topicTitle});

  @override
  Widget build(BuildContext context) {
    const buttonColor = Color.fromARGB(255, 231, 99, 110);

    return Scaffold(
      appBar: AppBar(
        title: Text(topicTitle, style: const TextStyle(fontSize: 18)),
        backgroundColor: const Color.fromARGB(255, 229, 117, 126),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LevelsPage(topicId: topicTitle),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 100),
                backgroundColor: buttonColor,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.quiz, color: Colors.white, size: 28),
                  SizedBox(width: 12),
                  Text(
                    'Quiz',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ArticlesPage(topic: topicTitle),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 100),
                backgroundColor: buttonColor,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.article, color: Colors.white, size: 28),
                  SizedBox(width: 12),
                  Text(
                    'Articles',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InfographicsPage(topic: topicTitle),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 100),
                backgroundColor: buttonColor,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.insert_chart_outlined,
                    color: Colors.white,
                    size: 28,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Infographics',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PlaceholderPage extends StatelessWidget {
  final String title;
  const PlaceholderPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color.fromARGB(255, 229, 117, 126),
      ),
      body: Center(
        child: Text(
          'This is the $title page.',
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}