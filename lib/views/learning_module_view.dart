import 'package:flutter/material.dart';
import 'package:aware_plus/models/learning_models.dart';
import 'package:aware_plus/views/quiz_view.dart';

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

  void _showFullImage(BuildContext context, String imagePath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            iconTheme: const IconThemeData(color: Colors.white),
            elevation: 0,
          ),
          body: Center(
            child: InteractiveViewer(
              clipBehavior: Clip.none,
              panEnabled: true,
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.asset(imagePath),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, LearningModels learningModel) {
    return Card(
      color: const Color(0xFFFFB3C1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ExpansionTile(
        title: Text(
          learningModel.title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        childrenPadding: const EdgeInsets.all(16),
        children: [
          if (learningModel.infographicImage != null)
            GestureDetector(
              onTap: () => _showFullImage(context, learningModel.infographicImage!),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  learningModel.infographicImage!,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            )
          else
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

          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Key Points:",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Color(0xFFC9184A),
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
        title: Text(
          subtopicId,
          style: const TextStyle(fontSize: 18, color: Colors.white),
        ),
        backgroundColor: const Color(0xFFC9184A),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ...learningModels.map((lm) => _buildSection(context, lm)),
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF4D6D),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        QuizPage(topicId: topicId, subtopicId: subtopicId),
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
