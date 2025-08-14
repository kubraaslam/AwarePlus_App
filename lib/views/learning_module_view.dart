import 'package:aware_plus/models/learning_models.dart';
import 'package:aware_plus/views/quiz_view.dart';
import 'package:flutter/material.dart';

class ModuleView extends StatelessWidget {
  final List<LearningModels> learningModels;
  final String topicId;
  final String subtopicId;

  const ModuleView({
    super.key,
    required this.learningModels,
    required this.topicId,
    required this.subtopicId,
  });

  Widget _buildSection(LearningModels learningModel) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ExpansionTile(
        title: Text(
          learningModel.title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFFE7636E),
          ),
        ),
        childrenPadding: const EdgeInsets.all(16),
        children: [
          // Infographic / Image placeholder
          Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(
              learningModel.infographicDesc,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54, fontSize: 16),
            ),
          ),
          const SizedBox(height: 12),

          // Key Points
          Align(
            alignment: Alignment.centerLeft,
            child: const Text(
              "Key Points:",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Color(0xFF2CB2BC),
              ),
            ),
          ),
          const SizedBox(height: 6),
          ...learningModel.keyPoints.map(
            (point) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("• "),
                  Expanded(
                    child: Text(point, style: const TextStyle(fontSize: 15)),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),
          // Quick Fact
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blueGrey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              "💡 Quick Fact: ${learningModel.quickFact}",
              style: const TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.blueGrey,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(subtopicId),
        backgroundColor: const Color(0xFFE7636E),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ...learningModels.map(_buildSection),
          const SizedBox(height: 20),

          // Single Start Quiz button at the bottom
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2CB2BC),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => QuizPage(
                          topicId: topicId,
                          subtopicId: subtopicId,
                        ),
                  ),
                );
              },
              child: const Text(
                "Start Quiz",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
