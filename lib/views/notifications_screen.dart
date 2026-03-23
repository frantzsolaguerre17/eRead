import 'package:flutter/material.dart';
import 'package:memo_livre/views/pdf_viewer_page.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../controllers/notifications_controller.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // 🔹 1. Fetch public notifications avant mark as read
    Future.microtask(() async {
      final controller = context.read<NotificationController>();

      await controller.fetchPublicNotifications(); // fetch d'abord
      await controller.markAllPublicAsRead(); // ensuite mark as read
      await controller.loadUnreadCount(); // badge
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // 🔹 Re-fetch si l'app revient
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final controller = context.read<NotificationController>();
      controller.fetchPublicNotifications();
      controller.loadUnreadCount();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<NotificationController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              "Notifications",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            Text(
              "Cliquez sur notification pour ouvrir et lire le livre ajouté",
              style: TextStyle(fontSize: 13, color: Colors.white),
            )
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Builder(
        builder: (_) {
          // 🔹 Loading
          if (controller.isLoadingPublic) {
            return _notificationsShimmer();
          }

          // 🔹 Empty state
          if (controller.publicNotifications.isEmpty) {
            return _emptyState();
          }

          // 🔹 ListView publique
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.publicNotifications.length,
            itemBuilder: (_, i) {
              final notif = controller.publicNotifications[i];

              // Sécurisation : n'affiche que type public
              if (notif['type'] != 'book_added') return const SizedBox();

              final isRead = notif['is_read'] == true;

              return _NotificationCard(
                message: notif['message'],
                date: DateTime.parse(notif['created_at']),
                isRead: isRead,
                bookId: notif['book_id'],
                onTap: () async {
                  await controller.markAsRead(notif['id']);
                  final book = await controller.getBookById(notif['book_id']);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => PdfViewerPage(book: book)),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.notifications_none, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            "Aucune notification",
            style: TextStyle(fontSize: 18, color: Colors.black54),
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
  final String bookId;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.message,
    required this.date,
    required this.isRead,
    required this.bookId,
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
            // 🔔 Icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isRead
                    ? Colors.grey.shade200
                    : Colors.deepPurple.shade100,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.menu_book_rounded, color: Colors.deepPurple),
            ),
            const SizedBox(width: 14),
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
                      color: Colors.deepPurple,
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
            // 🔵 Dot non lu
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

  static String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return "À l'instant";
    if (diff.inMinutes < 60) return "Il y a ${diff.inMinutes} min";
    if (diff.inHours < 24) return "Il y a ${diff.inHours} h";
    return "${date.day}/${date.month}/${date.year}";
  }
}

Widget _notificationsShimmer() {
  return ListView.builder(
    padding: const EdgeInsets.all(12),
    itemCount: 6,
    itemBuilder: (_, __) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );
    },
  );
}