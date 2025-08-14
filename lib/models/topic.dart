import 'package:aware_plus/models/subtopic.dart';

class Topic {
  final String title;
  final String description;
  final List<Subtopic> subtopics;

  Topic({
    required this.title,
    required this.description,
    required this.subtopics,
  });
}