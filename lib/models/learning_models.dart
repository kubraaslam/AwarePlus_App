class LearningModels {
  final String title;
  final String infographicDesc;
  final String? infographicImage;
  final List<String> keyPoints;
  final String quickFact;
  final String topicId;
  final String subtopicId;

  LearningModels({
    required this.title,
    required this.infographicDesc,
    this.infographicImage,
    required this.keyPoints,
    required this.quickFact,
    required this.topicId,
    required this.subtopicId,
  });
}
