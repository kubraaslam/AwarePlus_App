import 'package:flutter/material.dart';
import 'package:aware_plus/models/subtopic.dart';

class TopicDetailView extends StatelessWidget {
  final String topicTitle;
  final String topicDescription;
  final List<Subtopic> subtopics;

  const TopicDetailView({
    super.key,
    required this.topicTitle,
    required this.topicDescription,
    required this.subtopics,
  });

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF2CB2BC); // example color for badges

    return Scaffold(
      appBar: AppBar(
        title: Text(
          topicTitle,
          style: const TextStyle(fontSize: 18),
        ),
        backgroundColor: const Color(0xFFE5757E),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              topicTitle,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              topicDescription,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _InfoBadge(icon: Icons.access_time, label: '45 min', color: Colors.green),
                const SizedBox(width: 8),
                _InfoBadge(icon: Icons.menu_book, label: '${subtopics.length} modules', color: Colors.orange),
                const SizedBox(width: 8),
                _InfoBadge(icon: Icons.check_circle, label: '0/${subtopics.length} completed', color: Colors.blue),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Overall Progress', style: TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: 0, // Update this with actual progress
              color: primaryColor,
              backgroundColor: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: subtopics.length,
                itemBuilder: (context, index) {
                  final subtopic = subtopics[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(subtopic.title),
                      subtitle: Text(subtopic.description),
                      trailing: ElevatedButton(
                        onPressed: () => subtopic.onStart!(context),
                        child: const Text('Start'),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoBadge({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color)),
        ],
      ),
    );
  }
}