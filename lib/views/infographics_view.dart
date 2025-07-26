import 'package:aware_plus/data/infographics_data.dart';
import 'package:aware_plus/views/bookmark_view.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InfographicsPage extends StatefulWidget {
  final String topic;

  const InfographicsPage({super.key, required this.topic});

  @override
  State<InfographicsPage> createState() => _InfographicsPageState();
}

class _InfographicsPageState extends State<InfographicsPage> {
  late List<String> files;
  Set<String> bookmarked = {};

  @override
  void initState() {
    super.initState();
    files = topicInfographics[widget.topic] ?? [];
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      bookmarked = prefs.getStringList('bookmarkedInfographics')?.toSet() ?? {};
    });
  }

  Future<void> _toggleBookmark(String file) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (bookmarked.contains(file)) {
        bookmarked.remove(file);
      } else {
        bookmarked.add(file);
      }
      prefs.setStringList('bookmarkedInfographics', bookmarked.toList());
    });
  }

  void _showPopupImage(BuildContext context, String file) {
    final isBookmarked = bookmarked.contains(file);

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Stack(
            children: [
              InteractiveViewer(
                minScale: 1,
                maxScale: 4,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(file),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  icon: Icon(
                    isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 8,
                        color: const Color(0xB3000000),
                      ),
                    ],
                  ),
                  onPressed: () async {
                    Navigator.pop(context); // close popup
                    await _toggleBookmark(file); // update bookmark
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.topic} Infographics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmarks),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BookmarksPage()),
              );
            },
          ),
        ],
      ),
      body: files.isEmpty
          ? const Center(child: Text('No infographics available.'))
          : ListView.builder(
              itemCount: files.length,
              itemBuilder: (context, index) {
                final file = files[index];
                final isBookmarked = bookmarked.contains(file);

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        InkWell(
                          onTap: () => _showPopupImage(context, file),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.asset(
                              file,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: IconButton(
                            icon: Icon(
                              isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  blurRadius: 8,
                                  color: const Color(0xB3000000),
                                ),
                              ],
                            ),
                            onPressed: () => _toggleBookmark(file),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}