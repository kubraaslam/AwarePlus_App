import 'package:aware_plus/views/quiz_result_view.dart';
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
    quizQuestions = fetchQuizQuestionsByLevel(
      widget.topicId,
      widget.subtopicId,
    );
  }

  Future<List<Map<String, dynamic>>> fetchQuizQuestionsByLevel(
    String topicId,
    String subtopicId,
  ) async {
    final querySnapshot =
        await FirebaseFirestore.instance
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
        'correctAnswer': data['answer'],
      };
    }).toList();
  }

  void markLevelAsCompleted(String subtopicId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final userDoc = FirebaseFirestore.instance.collection('users').doc(userId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(userDoc);
      final existing = List<String>.from(
        snapshot.data()?['completedLevels'] ?? [],
      );
      if (!existing.contains(subtopicId)) {
        existing.add(subtopicId);
        transaction.update(userDoc, {'completedLevels': existing});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quiz"),
        backgroundColor: const Color.fromARGB(255, 209, 65, 113),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: quizQuestions,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading questions'));
          }

          final questions = snapshot.data ?? [];

          if (questions.isEmpty) {
            return const Center(child: Text('No questions found.'));
          }

          return QuizUI(
            questions: questions,
            onQuizCompleted: () {
              markLevelAsCompleted(widget.subtopicId);
              Navigator.pop(context);
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

  const QuizUI({
    super.key,
    required this.questions,
    required this.onQuizCompleted,
  });

  @override
  State<QuizUI> createState() => _QuizUIState();
}

class _QuizUIState extends State<QuizUI> with SingleTickerProviderStateMixin {
  int currentQuestionIndex = 0;
  int score = 0;
  String? selectedOption;
  bool answered = false;

  List<Map<String, dynamic>> answeredWidgets = [];

  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.forward();
  }

  void checkAnswer(String option) {
    if (answered) return;

    final question = widget.questions[currentQuestionIndex];
    final correctAnswer = question['correctAnswer'];

    setState(() {
      selectedOption = option;
      answered = true;
    });

    if (option == correctAnswer) {
      score++;
    }

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        answeredWidgets.add({
          'question': question['question'],
          'options': question['options'],
          'correctAnswer': correctAnswer,
          'selectedAnswer': option,
        });
      });

      if (currentQuestionIndex < widget.questions.length - 1) {
        _controller.reset();
        setState(() {
          currentQuestionIndex++;
          selectedOption = null;
          answered = false;
        });
        _controller.forward();
      } else {
        // ignore: use_build_context_synchronously
        Navigator.of(context)
            .pushReplacement(
              MaterialPageRoute(
                builder:
                    (context) => QuizResultPage(
                      score: score,
                      totalQuestions: widget.questions.length,
                    ),
              ),
            )
            .then((_) {
              widget.onQuizCompleted();
            });
      }
    });
  }

  Widget buildAnsweredQuestion(Map<String, dynamic> data) {
    final questionText = data['question'];
    final options = List<String>.from(data['options']);
    final correct = data['correctAnswer'];
    final selected = data['selectedAnswer'];

    return Padding(
      padding: const EdgeInsets.only(bottom: 30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            questionText,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          ...options.map((option) {
            final optClean = option.toString().trim().toLowerCase();
            final correctClean = correct.toString().trim().toLowerCase();
            final selectedClean = selected.toString().trim().toLowerCase();

            Color bgColor;
            if (optClean == correctClean) {
              bgColor = Colors.green;
            } else if (optClean == selectedClean) {
              bgColor = Colors.red;
            } else {
              bgColor = Colors.grey.shade300;
            }

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: ElevatedButton(
                onPressed: null,
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(bgColor),
                  foregroundColor: WidgetStateProperty.all(Colors.white),
                  padding: WidgetStateProperty.all(
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                  ),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(option, style: const TextStyle(fontSize: 15)),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.questions[currentQuestionIndex];

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(
              value: (currentQuestionIndex + 1) / widget.questions.length,
              backgroundColor: Colors.grey[300],
              color: const Color.fromARGB(255, 246, 154, 185),
              minHeight: 8,
            ),
            const SizedBox(height: 24),

            // Show previous answered questions
            ...answeredWidgets.map(buildAnsweredQuestion),

            // Show current question
            SlideTransition(
              position: _offsetAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Question ${currentQuestionIndex + 1}/${widget.questions.length}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    question['question'],
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ...question['options'].map<Widget>((option) {
                    Color buttonColor;
                    if (answered) {
                      final optClean = option.toString().trim().toLowerCase();
                      final correctClean =
                          question['correctAnswer']
                              .toString()
                              .trim()
                              .toLowerCase();
                      final selectedClean =
                          (selectedOption ?? "")
                              .toString()
                              .trim()
                              .toLowerCase();

                      if (optClean == correctClean) {
                        buttonColor = Colors.green;
                      } else if (optClean == selectedClean) {
                        buttonColor = Colors.red;
                      } else {
                        // No grey fallback, just keep default pink
                        buttonColor = Colors.pink.shade300;
                      }
                    } else {
                      buttonColor = Colors.pink.shade300;
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: ElevatedButton(
                        onPressed: answered ? null : () => checkAnswer(option),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            option,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
