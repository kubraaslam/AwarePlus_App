import 'package:aware_plus/data/article_data.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ArticlesPage extends StatelessWidget {
  final String topic;
  const ArticlesPage({super.key, required this.topic});

  @override
  Widget build(BuildContext context) {
    final articles = topicArticles[topic] ?? [];

    return Scaffold(
      appBar: AppBar(title: Text('$topic Articles', style: TextStyle(fontSize: 18),)),
      body: ListView.builder(
        itemCount: articles.length,
        itemBuilder: (context, index) {
          final article = articles[index];
          return ListTile(
            title: Text(article['title']!),
            trailing: const Icon(Icons.launch),
            onTap: () async {
              final url = Uri.parse(article['url']!);
              if (await canLaunchUrl(url)) {
                launchUrl(url);
              } else {
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Could not launch article')),
                );
              }
            },
          );
        },
      ),
    );
  }
}