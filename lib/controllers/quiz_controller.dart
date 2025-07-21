import 'package:aware_plus/models/quiz.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<List<QuizQuestion>> fetchQuizQuestions(String topicId) async {
  final querySnapshot =
      await FirebaseFirestore.instance
          .collection('quizzes')
          .doc(topicId)
          .collection('questions')
          .get();

  return querySnapshot.docs
      .map((doc) => QuizQuestion.fromMap(doc.data(), doc.id))
      .toList();
}
