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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          topicTitle,
          style: const TextStyle(fontSize: 18, color: Colors.white),
        ),
        backgroundColor: const Color(0xFFC9184A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
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
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _InfoBadge(
                  icon: Icons.access_time,
                  label: '2h',
                  color: Color(0xFFFF4D6D),
                ),
                _InfoBadge(
                  icon: Icons.menu_book,
                  label: '${subtopics.length} modules',
                  color: Color(0xFFA4133C),
                ),
                _InfoBadge(
                  icon: Icons.check_circle,
                  label: '0/${subtopics.length} completed',
                  color: Color(0xFF590D22),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Overall Progress',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: 0,
              color: const Color.fromARGB(255, 44, 188, 61),
              backgroundColor: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: subtopics.length,
              itemBuilder: (context, index) {
                final subtopic = subtopics[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(
                      subtopic.title,
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(subtopic.description),
                    trailing: ElevatedButton(
                      onPressed: () => subtopic.onStart!(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFF758F), // Button fill

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Start',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
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

  const _InfoBadge({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color)),
        ],
      ),
    );
  }
}
