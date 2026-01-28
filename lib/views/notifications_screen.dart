import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/notifications_controller.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    final controller = context.read<NotificationController>();

    // Charger initialement toutes les notifications depuis la DB
    controller.fetchNotifications();

    // Ensuite écouter le flux en temps réel
    controller.startListening();

    // Marquer tout comme lu (optionnel)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.markAllAsRead();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<NotificationController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),

      /// 🧠 APPBAR PREMIUM
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: false,
        title: const Text(
          "Notifications",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),

      body: controller.notifications.isEmpty
          ? _emptyState()
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.notifications.length,
        itemBuilder: (_, i) {
          final notif = controller.notifications[i];
          final isRead = notif['is_read'] == true;

          return _NotificationCard(
            message: notif['message'],
            date: DateTime.parse(notif['created_at']),
            isRead: isRead,
            onTap: () =>
                controller.markAsRead(notif['id']),
          );
        },
      ),
    );
  }

  /// 📭 EMPTY STATE
  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.notifications_none, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            "Aucune notification",
            style: TextStyle(
              fontSize: 18,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}


class _NotificationCard extends StatelessWidget {
  final String message;
  final DateTime date;
  final bool isRead;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.message,
    required this.date,
    required this.isRead,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(
            color: isRead
                ? Colors.transparent
                : Colors.deepPurple.withOpacity(0.4),
            width: 1.2,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔔 ICON
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isRead
                    ? Colors.grey.shade200
                    : Colors.deepPurple.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.book,
                color: isRead
                    ? Colors.grey
                    : Colors.deepPurple,
              ),
            ),

            const SizedBox(width: 14),

            /// 📝 CONTENT
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                      isRead ? FontWeight.w400 : FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatDate(date),
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black45,
                    ),
                  ),
                ],
              ),
            ),

            /// 🔵 DOT (NON LU)
            if (!isRead)
              Container(
                margin: const EdgeInsets.only(left: 8, top: 6),
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Colors.deepPurple,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// ⏱️ DATE FORMAT SIMPLE
  static String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);

    if (diff.inMinutes < 1) return "À l'instant";
    if (diff.inMinutes < 60) return "Il y a ${diff.inMinutes} min";
    if (diff.inHours < 24) return "Il y a ${diff.inHours} h";
    return "${date.day}/${date.month}/${date.year}";
  }
}
