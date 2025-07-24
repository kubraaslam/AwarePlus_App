import 'package:aware_plus/models/quiz.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> saveCompletedLevel(String subtopicId) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return;

  final userRef = FirebaseFirestore.instance.collection('users').doc(userId);

  await userRef.set({
    'completedLevels': FieldValue.arrayUnion([subtopicId])
  }, SetOptions(merge: true));
}

Future<List<String>> getCompletedLevels(String topicId) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return [];

  final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
  final completed = doc.data()?['completedLevels'] ?? [];

  return List<String>.from(completed);
}

Future<List<QuizQuestion>> fetchQuizQuestionsByLevel(String topicId, String subtopicId) async {
  final querySnapshot = await FirebaseFirestore.instance
      .collection('quizzes')
      .doc(topicId)
      .collection('subtopics')      
      .doc(subtopicId)                 
      .collection('questions')
      .get();

  return querySnapshot.docs
      .map((doc) => QuizQuestion.fromMap(doc.data(), doc.id))
      .toList();
}