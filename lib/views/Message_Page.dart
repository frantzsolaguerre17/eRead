import 'package:flutter/material.dart';
import 'package:memo_livre/controllers/MessageController.dart';
import 'package:memo_livre/views/profil_page.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class PrivateNotificationsScreen extends StatefulWidget {
  const PrivateNotificationsScreen({super.key});

  @override
  State<PrivateNotificationsScreen> createState() =>
      _PrivateNotificationsScreenState();
}

class _PrivateNotificationsScreenState
    extends State<PrivateNotificationsScreen> {

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      final controller = context.read<MessageController>();

      controller.startListening();

      controller.markAllAsRead(); // ✔ ici
      controller.fetchNotifications();
      controller.loadUnreadCount();
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [

            Text(
              "Mes messages",
              style: TextStyle(
                fontSize: 22,
                color: Colors.white,
              ),
            ),

            SizedBox(height: 2),

            Text(
              "Vous verrez ici si votre livre est accepté ou refusé.",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),

          ],
        ),

        actions: [
          IconButton(
              icon: const Icon(Icons.account_circle, color: Colors.white),
              tooltip: "Account profil",
              onPressed: () async{
                await Navigator.push(context,
                    MaterialPageRoute(
                        builder: (context) => const ProfilePage()
                    )
                );
              }
          ),
        ],
      ),

      body: Consumer<MessageController>(
        builder: (_, controller, __) {

          if (controller.isLoading) {
            return _messagesShimmer(context);
          }

          if (controller.notifications.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  Icon(
                    Icons.mark_email_read_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),

                  SizedBox(height: 20),

                  Text(
                    "Aucun message",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  SizedBox(height: 8),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    child: Text(
                      "Lorsque vous ajoutez un livre, vous recevrez ici un message indiquant si votre livre a été approuvé ou refusé.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ),

                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: controller.notifications.length,
            itemBuilder: (context, index) {

              final notif = controller.notifications[index];

              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 6),

                child: ListTile(

                  leading: CircleAvatar(
                    backgroundColor: notif.isRead
                        ? Colors.grey.shade300
                        : Colors.blue.shade100,
                    child: Icon(
                      Icons.mail_outline,
                      color: notif.isRead
                          ? Colors.grey
                          : Colors.blue,
                    ),
                  ),

                  title: Text(
                    notif.message,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  subtitle: Text(
                   _formatDate(notif.createdAt) ,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              );
            },
          );
        },
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



Widget _messagesShimmer(BuildContext context) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;

  return ListView.builder(
    padding: const EdgeInsets.all(12),
    itemCount: 6,
    itemBuilder: (_, __) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Shimmer.fromColors(
          baseColor: isDark
              ? Colors.grey[800]!   // 🌙 dark mode
              : Colors.grey[300]!,  // ☀️ light mode
          highlightColor: isDark
              ? Colors.grey[700]!
              : Colors.grey[100]!,
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );
    },
  );
}