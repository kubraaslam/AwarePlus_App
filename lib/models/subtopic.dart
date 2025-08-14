import 'package:flutter/material.dart';

class Subtopic {
  final String title;
  final String description;
  final void Function(BuildContext)? onStart;

  Subtopic({
    required this.title,
    required this.description,
    required this.onStart,
  });
}

