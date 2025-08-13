import 'package:aware_plus/views/topic_detail_view.dart';
import 'package:aware_plus/widgets/bottom_nav_bar.dart';
import 'package:flutter/material.dart';

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
    final filteredTopics =
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
          backgroundColor: const Color(0xFFE7636E),
          elevation: 0,
          title: const Text(
            'Knowledge Center',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
        ),
      ),
      body: SafeArea(
        child: Padding(
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
                child: ListView.builder(
                  itemCount: filteredTopics.length,
                  itemBuilder:
                      (context, index) =>
                          _buildTopicTile(context, filteredTopics[index]),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 1, // Knowledge tab index
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 1:
              break; // Stay on Knowledge
            case 2:
              Navigator.pushReplacementNamed(context, '/support');
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/profile');
              break;
          }
        },
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
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
    );
  }
}
