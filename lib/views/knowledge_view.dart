import 'package:aware_plus/views/bookmark_view.dart';
import 'package:aware_plus/views/topic_detail_view.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class KnowledgeView extends StatefulWidget {
  const KnowledgeView({super.key});

  @override
  State<KnowledgeView> createState() => _KnowledgeViewState();
}

class _KnowledgeViewState extends State<KnowledgeView> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _allTopics = [
    'Sexual and Reproductive Health Education',
    'Physical Sexual Health',
    'Rights, Laws & Ethics',
    'Myths & Misconceptions',
  ];

  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    List<String> filteredTopics =
        _allTopics
            .where(
              (topic) =>
                  topic.toLowerCase().contains(_searchQuery.toLowerCase()),
            )
            .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: const Color.fromARGB(255, 229, 117, 126),
          elevation: 0,
          flexibleSpace: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 15),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Knowledge Center',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Search Box
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search topics',
                prefixIcon: const Icon(Icons.search),
                fillColor: Colors.grey[200],
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            const SizedBox(height: 20),

            // Topic Cards
            Expanded(
              child: ListView(
                children:
                    filteredTopics
                        .map((topic) => _buildTopicTile(context, topic))
                        .toList(),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: const Color.fromARGB(255, 229, 117, 126),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 8),
          child: SizedBox(
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNavItem(
                  Icons.bookmark_border,
                  'Bookmarks',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const BookmarksPage()),
                    );
                  },
                ),
                _buildNavItem(
                  Icons.share,
                  'Share',
                  onTap: () {
                    SharePlus.instance.share(
                      ShareParams(
                        text:
                            'Check out this great content on sexual health education from the Aware+ app!\n\nExplore now: https://awareplus.app',
                        subject: 'Explore Knowledge with Aware+',
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildTopicTile(BuildContext context, String title) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Colors.black26, width: 1),
      ),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: ListTile(
          title: Text(title),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TopicDetailView(topicTitle: title),
              ),
            );
          },
        ),
      ),
    );
  }
}
