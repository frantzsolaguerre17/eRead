import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
    _initUser();
  }

  Future<void> _initUser() async {
    final chat = context.read<GroupChatController>();

    await chat.loadCurrentUser();
    chat.startListening();
  }


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
              reverse: false,
              controller: scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: chat.messages.length,
              itemBuilder: (_, i) {
                final msg = chat.messages[i];

                final message = msg['message'] ?? '';
                final username = msg['username'] ?? 'Utilisateur';
                final createdAt = msg['created_at'] ?? DateTime.now().toIso8601String();

                final date = DateTime.parse(msg['created_at']).toLocal();

                final isMe = msg['user_id'] == chat.currentUserId;

                bool showHeader = false;

                if (i == 0) {
                  // premier élément affiché (le plus récent)
                  showHeader = true;
                } else {
                  final previousMsg = chat.messages[i - 1];
                  final previousDate =
                  DateTime.parse(previousMsg['created_at']).toLocal();

                  showHeader =
                      date.day != previousDate.day ||
                          date.month != previousDate.month ||
                          date.year != previousDate.year;
                }

                return Column(
                  children: [
                    if (showHeader)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
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
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),

                    _ChatBubble(
                      message: message,
                      username: username,
                      date: DateTime.parse(createdAt).toLocal(),
                      isMe: msg['user_id'] == chat.currentUserId,
                      role: msg['role'] ?? 'user',
                    )

                  ],
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
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: isMe
              ? Colors.deepPurple
              : isAdmin
              ? Colors.orange.shade50   // 👈 fond admin
              : const Color(0xFFF6F6F6),
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
              Row(
                children: [
                  Text(
                    username,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isAdmin ? Colors.orange.shade50 : Colors.deepPurple,
                    ),
                  ),
                  if (isAdmin) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        "ADMIN",
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ]
                ],
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
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 12,
              color: Colors.black.withOpacity(0.08),
              offset: const Offset(0, -2),
            )
          ],
        ),
        child: Row(
          children: [
            /// champ texte
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F1F1),
                  borderRadius: BorderRadius.circular(25),
                ),
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
            ),

            const SizedBox(width: 8),

            /// bouton envoyer
            GestureDetector(
              onTap: onSend,
              child: Container(
                height: 46,
                width: 46,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.deepPurple,
                ),
                child: const Icon(Icons.send, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
