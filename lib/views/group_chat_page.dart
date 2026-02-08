import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/group_chat_controller.dart';

class GroupChatScreen extends StatefulWidget {
  const GroupChatScreen({super.key});

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final controller = TextEditingController();
  final scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
   // context.read<GroupChatController>().startListening();
  }

  @override
  Widget build(BuildContext context) {
    final chat = context.watch<GroupChatController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text("Communauté", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),),
        centerTitle: true,
      ),
      body: Column(
        children: [
          /// 💬 MESSAGES
          Expanded(
            child: ListView.builder(
              reverse: true,
              controller: scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: chat.messages.length,
              itemBuilder: (_, i) {
                final msg = chat.messages[chat.messages.length - 1 - i];
                final isMe = msg['user_id'] == chat.currentUserId;

                return _ChatBubble(
                  message: msg['message'],
                  username: msg['username'],
                  date: DateTime.parse(msg['created_at']).toLocal(),
                  isMe: isMe,
                );
              },
            ),
          ),

          /// ✍️ INPUT
          _ChatInput(
            controller: controller,
            onSend: () {
              if (controller.text.trim().isEmpty) return;
              chat.sendMessage(controller.text.trim());
              controller.clear();
            },
          ),
        ],
      ),
    );
  }
}



class _ChatBubble extends StatelessWidget {
  final String message;
  final String username;
  final DateTime date;
  final bool isMe;

  const _ChatBubble({
    required this.message,
    required this.username,
    required this.date,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: isMe ? Colors.deepPurple : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
          isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Text(
                username,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            Text(
              message,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black87,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(date),
              style: TextStyle(
                fontSize: 11,
                color: isMe ? Colors.white70 : Colors.black45,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatTime(DateTime date) {
    return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }
}



class _ChatInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const _ChatInput({
    required this.controller,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 8,
              color: Colors.black12,
            )
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: "Écrire un message...",
                  border: InputBorder.none,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send, color: Colors.deepPurple),
                onPressed: () {
                  if (controller.text.trim().isEmpty) return;

                  context.read<GroupChatController>().sendMessage(controller.text.trim());
                  controller.clear();
                }

            ),
          ],
        ),
      ),
    );
  }
}
