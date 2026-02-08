import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/book.dart';

class NotificationController extends ChangeNotifier {
  final _supabase = Supabase.instance.client;

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

    final data = await _supabase
        .from('notifications')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    notifications = List<Map<String, dynamic>>.from(data);
    unreadCount = notifications.where((n) => n['is_read'] == false).length;

    isLoading = false;
    notifyListeners();
  }


  /// 👁️ Marquer comme lu
  Future<void> markAsRead(String id) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    await _supabase
        .from('notifications')
        .update({'is_read': true})
        .eq('id', id)
        .eq('user_id', user.id); // 🔐 sécurité
  }


  /// Tout marquer comme lu
  Future<void> markAllAsRead() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    await _supabase
        .from('notifications')
        .update({'is_read': true})
        .eq('user_id', user.id)
        .eq('is_read', false);

    unreadCount = 0;
    notifyListeners();
  }


  Future<void> fetchUnreadCount() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    final data = await _supabase
        .from('notifications')
        .select('id')
        .eq('user_id', user.id)
        .eq('is_read', false);

    unreadCount = data.length;
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
