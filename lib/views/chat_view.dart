import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatPage extends StatefulWidget {
  final String counselorId;
  const ChatPage({super.key, required this.counselorId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final currentUser = FirebaseAuth.instance.currentUser;

  late final String chatId;

  @override
  void initState() {
    super.initState();
    if (currentUser != null) {
      chatId = "${currentUser!.uid}_${widget.counselorId}";
    }
  }

  void _sendMessage() async {
    if (_controller.text.trim().isEmpty || currentUser == null) return;

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add({
      'text': _controller.text.trim(),
      'senderId': currentUser!.uid,
      'timestamp': FieldValue.serverTimestamp(),
    });

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return const Center(child: Text('Please log in first.'));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFE7636E),
        title: const Text("Chat with SSS"),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(chatId)
                  .collection('messages')
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;

                return ListView(
                  padding: const EdgeInsets.all(10),
                  children: messages.map((doc) {
                    final data = doc.data();
                    final isUser = data['senderId'] == currentUser!.uid;
                    return Align(
                      alignment:
                          isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin:
                            const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isUser ? Colors.pink[300] : Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          data['text'],
                          style: TextStyle(
                              color: isUser ? Colors.white : Colors.black87),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: Colors.grey[100],
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                        hintText: "Type a message...", border: InputBorder.none),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.pink),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}