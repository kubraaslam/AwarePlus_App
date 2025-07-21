class QuizQuestion {
  final String id;
  final String question;
  final List<String> options;
  final String correctAnswer;

  QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswer,
  });

  factory QuizQuestion.fromMap(Map<String, dynamic> data, String id) {
    return QuizQuestion(
      id: id,
      question: data['question'] ?? '',
      options: List<String>.from(data['options'] ?? []),
      correctAnswer: data['answer'] ?? '', // 'answer' is the field in Firebase
    );
  }
}