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
        .eq('type', 'book_added')
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
  /*Future<void> markAllAsRead(String type) async {

    final user = _supabase.auth.currentUser;

    await _supabase
        .from('notifications')
        .update({'is_read': true})
        .eq('type', type)
        .eq('user_id', user!.id);

    unreadCount = 0;
    notifyListeners();

  }*/


  Future<void> markAllAsRead() async {

    final user = _supabase.auth.currentUser;

    await _supabase
        .from('notifications')
        .update({'is_read': true})
        .eq('type', 'book_added')
        .neq('user_id', user!.id);

    unreadCount = 0;

    notifyListeners();
  }


  Future<int> getUnreadCount(String type) async {

    final user = _supabase.auth.currentUser;

    final data = await _supabase
        .from('notifications')
        .select()
        .eq('type', type)
        .eq('is_read', false)
        .eq('user_id', user!.id);

    return data.length;

  }


  Future<void> loadUnreadCount() async {

    final user = _supabase.auth.currentUser;

    final data = await _supabase
        .from('notifications')
        .select()
        .eq('type', 'book_added')
        .eq('is_read', false)
        .neq('user_id', user!.id);

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
