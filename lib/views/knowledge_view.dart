import 'package:aware_plus/views/topic_detail_view.dart';
import 'package:flutter/material.dart';

class KnowledgeView extends StatelessWidget {
  const KnowledgeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: const Color.fromARGB(255, 229, 117, 126),
          elevation: 0,
          flexibleSpace: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 15),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
                SizedBox(width: 8),
                Text(
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
        child: ListView(
          children: [
            // Search Box
            TextField(
              decoration: InputDecoration(
                hintText: 'Search topics',
                prefixIcon: Icon(Icons.search),
                fillColor: Colors.grey[200],
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 20),

            // Topic Cards
            _buildTopicTile(
              context,
              'Sexual and Reproductive Health Education'
            ),
            _buildTopicTile(context, 'Physical Sexual Health'),
            _buildTopicTile(context, 'Rights, Laws & Ethics'),
            _buildTopicTile(context, 'Myths & Misconceptions'),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: const Color.fromARGB(255, 229, 117, 126),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 8),
          child: SizedBox(
            height: 50, // Fixed height prevents overflow
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNavItem(Icons.bookmark_border, 'Bookmark'),
                _buildNavItem(Icons.share, 'Share'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20),
        SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildTopicTile(BuildContext context, String title) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.black26, width: 1),
      ),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: ListTile(
          title: Text(title),
          trailing: Icon(Icons.arrow_forward_ios),
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
