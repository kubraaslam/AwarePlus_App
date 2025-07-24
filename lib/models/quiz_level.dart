import 'package:aware_plus/models/quiz.dart';

class QuizLevel {
  final String id;
  final String title;
  final List<QuizQuestion> questions;

  QuizLevel({required this.id, required this.title, required this.questions});
}