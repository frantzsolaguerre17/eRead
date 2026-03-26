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
    Future.microtask(() async {
      final chat = context.read<GroupChatController>();
      await chat.loadCurrentUser();
      chat.startListening();
    });
  }

  /// Format date pour le header
  String formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) return "Aujourd’hui";
    if (messageDate == today.subtract(const Duration(days: 1))) return "Hier";
    return "${date.day}/${date.month}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    final chat = context.watch<GroupChatController>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text("Communauté"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          /// Messages
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: chat.messages.length,
              itemBuilder: (_, i) {
                final msg = chat.messages[i];
                final date = DateTime.parse(msg['created_at']).toLocal();
                final isMe = msg['user_id'] == chat.currentUserId;
                final role = msg['role'] ?? 'user';

                // Vérifier si header de date à afficher
                bool showHeader = false;
                if (i == 0) {
                  showHeader = true;
                } else {
                  final prevDate =
                  DateTime.parse(chat.messages[i - 1]['created_at']).toLocal();
                  showHeader =
                      prevDate.day != date.day ||
                          prevDate.month != date.month ||
                          prevDate.year != date.year;
                }

                return Column(
                  crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    if (showHeader)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black12,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              formatDateHeader(date),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                        ),
                      ),
                    _ChatBubble(
                      message: msg['message'],
                      username: msg['username'],
                      date: date,
                      isMe: isMe,
                      role: role,
                    )
                  ],
                );
              },
            ),
          ),

          /// Input
          SafeArea(
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      minLines: 1,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: "Écrire un message...",
                        filled: true,
                        fillColor: Colors.grey.shade200,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      if (controller.text.trim().isEmpty) return;
                      chat.sendMessage(controller.text.trim());
                      controller.clear();
                      // Scroll vers le bas
                      Future.delayed(const Duration(milliseconds: 100), () {
                        scrollController.animateTo(
                          scrollController.position.maxScrollExtent,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        );
                      });
                    },
                    child: Container(
                      height: 46,
                      width: 46,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.deepPurple,
                      ),
                      child: const Icon(Icons.send, color: Colors.white),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

/// Widget pour afficher chaque message
class _ChatBubble extends StatelessWidget {
  final String message;
  final String username;
  final DateTime date;
  final bool isMe;
  final String role;

  const _ChatBubble({
    required this.message,
    required this.username,
    required this.date,
    required this.isMe,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    final isAdmin = role == 'admin';

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: isMe
              ? Colors.deepPurple
              : isAdmin
              ? Colors.orange.shade50
              : Colors.white,
          border: isAdmin && !isMe
              ? Border.all(color: Colors.orange, width: 1)
              : null,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment:
          isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Text(
                username + (isAdmin ? " (ADMIN)" : ""),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isAdmin ? Colors.orange : Colors.deepPurple,
                ),
              ),
            Text(
              message,
              style: TextStyle(
                fontSize: 15,
                color: isMe ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}",
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
}