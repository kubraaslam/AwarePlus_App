import 'package:aware_plus/controllers/quiz_controller.dart';
import 'package:aware_plus/models/quiz.dart';
import 'package:aware_plus/views/quiz_result_view.dart';
import 'package:flutter/material.dart';

class QuizPage extends StatefulWidget {
  final String topicId;

  const QuizPage({super.key, required this.topicId});

  @override
  QuizPageState createState() => QuizPageState();
}

class QuizPageState extends State<QuizPage> {
  late Future<List<QuizQuestion>> _questionsFuture;
  Map<int, String> selectedAnswers = {};
  int score = 0;

  @override
  void initState() {
    super.initState();
    _questionsFuture = fetchQuizQuestions(widget.topicId);
  }

  void calculateScore(List<QuizQuestion> questions) {
    int correctCount = 0;
    for (int i = 0; i < questions.length; i++) {
      if (selectedAnswers[i] == questions[i].correctAnswer) {
        correctCount++;
      }
    }
    setState(() {
      score = correctCount;
    });
  }

  void showScoreDialog(int total) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Quiz Submitted 🎉"),
            content: Text("You scored $score out of $total"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Interactive Quiz"),
        backgroundColor: Colors.pink[100],
        elevation: 0,
      ),
      body: FutureBuilder<List<QuizQuestion>>(
        future: _questionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text("Error loading quiz"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No questions found"));
          }

          final questions = snapshot.data!;

          return Column(
            children: [
              LinearProgressIndicator(
                value: selectedAnswers.length / questions.length,
                backgroundColor: Colors.grey[300],
                color: Colors.pinkAccent,
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: questions.length,
                  itemBuilder: (context, index) {
                    final question = questions[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Q${index + 1}: ${question.question}",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ...question.options.map((option) {
                              bool isSelected =
                                  selectedAnswers[index] == option;
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Radio<String>(
                                  value: option,
                                  groupValue: selectedAnswers[index],
                                  onChanged: (value) {
                                    setState(() {
                                      selectedAnswers[index] = value!;
                                    });
                                  },
                                  activeColor: Colors.pinkAccent,
                                ),
                                title: Text(option),
                                tileColor: isSelected ? Colors.pink[50] : null,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: ElevatedButton(
                  onPressed:
                      selectedAnswers.length == questions.length
                          ? () {
                            calculateScore(questions);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => QuizResultPage(
                                      score: score,
                                      total: questions.length,
                                    ),
                              ),
                            );
                          }
                          : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text("Submit Quiz"),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
