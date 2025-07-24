import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QuizPage extends StatefulWidget {
  final String topicId;
  final String subtopicId;

  const QuizPage({super.key, required this.topicId, required this.subtopicId});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  late Future<List<Map<String, dynamic>>> quizQuestions;

  @override
  void initState() {
    super.initState();
    quizQuestions = fetchQuizQuestionsByLevel(widget.topicId, widget.subtopicId);
  }

  Future<List<Map<String, dynamic>>> fetchQuizQuestionsByLevel(
      String topicId, String subtopicId) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('quizzes')
        .doc(topicId)
        .collection('subtopics')
        .doc(subtopicId)
        .collection('questions')
        .get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'question': data['question'],
        'options': List<String>.from(data['options']),
        'correctAnswer': data['correctAnswer'],
      };
    }).toList();
  }

  void markLevelAsCompleted(String subtopicId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final userDoc =
        FirebaseFirestore.instance.collection('users').doc(userId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(userDoc);
      final existing = List<String>.from(snapshot.data()?['completedLevels'] ?? []);
      if (!existing.contains(subtopicId)) {
        existing.add(subtopicId);
        transaction.update(userDoc, {'completedLevels': existing});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Quiz")),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: quizQuestions,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading questions'));
          }

          final questions = snapshot.data ?? [];

          if (questions.isEmpty) {
            return const Center(child: Text('No questions found.'));
          }

          return QuizUI(
            questions: questions,
            onQuizCompleted: () {
              markLevelAsCompleted(widget.subtopicId);
              Navigator.pop(context); // Return to LevelsPage
            },
          );
        },
      ),
    );
  }
}

class QuizUI extends StatefulWidget {
  final List<Map<String, dynamic>> questions;
  final VoidCallback onQuizCompleted;

  const QuizUI({super.key, required this.questions, required this.onQuizCompleted});

  @override
  State<QuizUI> createState() => _QuizUIState();
}

class _QuizUIState extends State<QuizUI> {
  int currentQuestionIndex = 0;
  int score = 0;

  void checkAnswer(String selectedOption) {
    final currentQuestion = widget.questions[currentQuestionIndex];
    if (selectedOption == currentQuestion['correctAnswer']) {
      score++;
    }

    if (currentQuestionIndex < widget.questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Quiz Completed!'),
          content: Text('Your score: $score / ${widget.questions.length}'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onQuizCompleted();
              },
              child: const Text('OK'),
            )
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.questions[currentQuestionIndex];
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Q${currentQuestionIndex + 1}: ${question['question']}",
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 16),
          ...question['options'].map<Widget>((option) {
            return ElevatedButton(
              onPressed: () => checkAnswer(option),
              child: Text(option),
            );
          }).toList(),
        ],
      ),
    );
  }
}