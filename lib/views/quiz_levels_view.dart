import 'package:aware_plus/views/quiz_view.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LevelsPage extends StatelessWidget {
  final String topicId;

  const LevelsPage({super.key, required this.topicId});

  Future<List<String>> fetchSubtopics(String topicId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('quizzes')
        .doc(topicId)
        .collection('subtopics')
        .get();

    return snapshot.docs.map((doc) => doc.id).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$topicId - Quiz Levels'),
        backgroundColor: const Color.fromARGB(255, 229, 117, 126),
      ),
      body: FutureBuilder<List<String>>(
        future: fetchSubtopics(topicId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final subtopics = snapshot.data ?? [];

          if (subtopics.isEmpty) {
            return const Center(child: Text('No quiz levels found.'));
          }

          return ListView.builder(
            itemCount: subtopics.length,
            itemBuilder: (context, index) {
              final subtopic = subtopics[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 231, 99, 110),
                    minimumSize: const Size(double.infinity, 80),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuizPage(
                          topicId: topicId,
                          subtopicId: subtopic,
                        ),
                      ),
                    );
                  },
                  child: Text(
                    subtopic,
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}