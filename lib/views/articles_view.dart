import 'package:aware_plus/data/article_data.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ArticlesPage extends StatelessWidget {
  final String topic;
  const ArticlesPage({super.key, required this.topic});

  Future<void> _launchUrl(BuildContext context, String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      ScaffoldMessenger.of(
        // ignore: use_build_context_synchronously
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not launch article')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final articles = topicArticles[topic] ?? [];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 229, 117, 126),
        title: Text(
          '$topic Articles',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        elevation: 2,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        itemCount: articles.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final article = articles[index];
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 3,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 16,
              ),
              title: Text(
                article['title'] ?? '',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(
                article['url'] ?? '',
                style: TextStyle(color: Colors.blue.shade700, fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
              trailing: const Icon(Icons.launch, color: Colors.blueAccent),
              onTap: () => _launchUrl(context, article['url'] ?? ''),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        },
      ),
    );
  }
}
