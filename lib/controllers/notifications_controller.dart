import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/book.dart';
import '../services/notification_service.dart';

class NotificationController extends ChangeNotifier {

  final _supabase = Supabase.instance.client;

  final PublicNotificationService _service =
  PublicNotificationService();

  List<Map<String, dynamic>> notifications = [];

  int unreadCount = 0;
  bool isLoading = true;

  StreamSubscription<List<Map<String, dynamic>>>? _subscription;

  /// 🔥 REALTIME
  void startListening() {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    _subscription = _supabase
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', user.id)
        .listen((data) {
      notifications = List<Map<String, dynamic>>.from(data);

      // 🔥 recalcul propre
      unreadCount =
          notifications.where((n) => n['is_read'] == false).length;

      notifyListeners();
    });

  }


  /// 📥 Chargement initial
  Future<void> fetchNotifications() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    isLoading = true;
    notifyListeners();

    final data = await _supabase.rpc('get_public_notifications', params: {
      'user_uuid': user.id,
    });

    notifications = List<Map<String, dynamic>>.from(data);

    unreadCount =
        notifications.where((n) => n['is_read'] == false).length;

    isLoading = false;
    notifyListeners();
  }

  /// 👁️ Marquer comme lu
  /*Future<void> markAsRead(String id) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    await _supabase
        .from('notifications')
        .update({'is_read': true})
        .eq('id', id)
        .eq('user_id', user.id); // 🔐 sécurité
  }*/


  Future<void> markAsRead(String notificationId) async {

    final user = _supabase.auth.currentUser;

    await _supabase
        .from('notification_reads')
        .insert({
      'notification_id': notificationId,
      'user_id': user!.id
    });

    await loadUnreadCount();
  }


  Future<bool> isRead(String notificationId) async {

    final user = _supabase.auth.currentUser;

    final data = await _supabase
        .from('notification_reads')
        .select()
        .eq('notification_id', notificationId)
        .eq('user_id', user!.id)
        .maybeSingle();

    return data != null;
  }



  Future<void> loadUnreadCount() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    final data = await _supabase.rpc(
      'get_public_notifications',
      params: {'user_uuid': user.id},
    );

    final list = List<Map<String, dynamic>>.from(data);

    unreadCount = list.where((n) => n['is_read'] == false).length;

    notifyListeners();
  }

  Future<void> markAllAsRead() async {

    await _service.markAllAsRead();

    unreadCount = 0;

    notifyListeners();
  }


  Future<Book> getBookById(String bookId) async {
    final res = await Supabase.instance.client
        .from('book')
        .select()
        .eq('id', bookId)
        .single();

    return Book.fromJson(res);
  }



  Future<void> markAllPublicAsRead() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    final notifs = await _supabase
        .from('notifications')
        .select('id')
        .eq('type', 'book_added');

    if (notifs.isEmpty) return;

    final reads = notifs.map((n) => {
      'notification_id': n['id'],
      'user_id': user.id,
    }).toList();

    /// 🔥 ICI LA CORRECTION
    await _supabase.from('notification_reads').upsert(
      reads,
      onConflict: 'notification_id,user_id',
    );

    /// 🔥 IMPORTANT → recalcul réel
    await loadUnreadCount();

    notifyListeners();
  }


  void reset() {
    notifications.clear();
    unreadCount = 0;
    //_subscription?.unsubscribe();
    _subscription = null;
    notifyListeners();
  }


  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

}
