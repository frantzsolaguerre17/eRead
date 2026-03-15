import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/NotificationModel.dart';
import '../services/MessageService.dart';

class Messagecontroller extends ChangeNotifier {

  final NotificationService _service = NotificationService();
  final _supabase = Supabase.instance.client;

  List<NotificationModel> notifications = [];

  bool isLoading = false;
  int unreadCount = 0;

  Future<void> fetchNotifications() async {

    isLoading = true;
    notifyListeners();

    final data = await _service.fetchPrivateNotifications();

    notifications = data
        .map((e) => NotificationModel.fromMap(e))
        .toList();

    isLoading = false;
    notifyListeners();
  }


  Future<void> markAsRead(String id) async {

    await _service.markAsRead(id);

    final index = notifications.indexWhere((n) => n.id == id);

    if(index != -1){
      notifications[index] = NotificationModel(
        id: notifications[index].id,
        message: notifications[index].message,
        isRead: true,
        createdAt: notifications[index].createdAt,
      );
    }

    notifyListeners();
  }


  Future<void> loadUnreadCount() async {

    final user = _supabase.auth.currentUser;

    final data = await _supabase
        .from('notifications')
        .select()
        .eq('type', 'private_message')
        .eq('user_id', user!.id)
        .eq('is_read', false);

    unreadCount = data.length;

    notifyListeners();
  }


  Future<void> markAllAsRead() async {

    final user = _supabase.auth.currentUser;

    await _supabase
        .from('notifications')
        .update({'is_read': true})
        .eq('type', 'private_message')
        .eq('user_id', user!.id);

    unreadCount = 0;

    notifyListeners();
  }

}