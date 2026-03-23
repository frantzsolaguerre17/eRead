import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/book.dart';
import '../services/notification_service.dart';

class NotificationController extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  final PublicNotificationService _service = PublicNotificationService();

  /// 🔹 Séparation public / privé
  List<Map<String, dynamic>> publicNotifications = [];
  List<Map<String, dynamic>> privateNotifications = [];

  int unreadCount = 0; // badge public
  bool isLoadingPublic = true;

  StreamSubscription<List<Map<String, dynamic>>>? _privateSubscription;

  /// 🔹 REALTIME : notifications privées uniquement
  void startListeningPrivate() {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    _privateSubscription = _supabase
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', user.id)
        .listen((data) {
      privateNotifications = List<Map<String, dynamic>>.from(data);
      notifyListeners();
    });
  }

  /// 🔹 Fetch notifications publiques
  Future<void> fetchPublicNotifications() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    isLoadingPublic = true;
    notifyListeners();

    final data = await _supabase.rpc(
      'get_public_notifications',
      params: {'user_uuid': user.id},
    );

    publicNotifications = List<Map<String, dynamic>>.from(data);
    isLoadingPublic = false;
    notifyListeners();
  }

  /// 🔹 Mark single notification as read (public)
  Future<void> markAsRead(String notificationId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    await _supabase
        .from('notification_reads')
        .insert({'notification_id': notificationId, 'user_id': user.id});

    await loadUnreadCount();
  }

  /// 🔹 Check if notification is read
  Future<bool> isRead(String notificationId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return false;

    final data = await _supabase
        .from('notification_reads')
        .select()
        .eq('notification_id', notificationId)
        .eq('user_id', user.id)
        .maybeSingle();

    return data != null;
  }

  /// 🔹 Charger compteur badge public
  Future<void> loadUnreadCount() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    final count = await _supabase.rpc(
      'get_unread_public_count',
      params: {'user_uuid': user.id},
    );

    unreadCount = count ?? 0;
    notifyListeners();
  }

  /// 🔹 Marquer toutes les notifications publiques comme lues
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

    await _supabase.from('notification_reads').upsert(
      reads,
      onConflict: 'notification_id,user_id',
    );

    await loadUnreadCount();
  }

  /// 🔹 Marquer toutes les notifications privées comme lues (optionnel)
  Future<void> markAllPrivateAsRead() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    final notifs = await _supabase
        .from('notifications')
        .select('id')
        .eq('user_id', user.id)
        .neq('type', 'book_added'); // exclure public

    if (notifs.isEmpty) return;

    final reads = notifs.map((n) => {
      'notification_id': n['id'],
      'user_id': user.id,
    }).toList();

    await _supabase.from('notification_reads').upsert(
      reads,
      onConflict: 'notification_id,user_id',
    );
  }

  /// 🔹 Obtenir un livre par id
  Future<Book> getBookById(String bookId) async {
    final res = await _supabase
        .from('book')
        .select()
        .eq('id', bookId)
        .single();

    return Book.fromJson(res);
  }

  /// 🔹 Reset controller
  void reset() {
    publicNotifications.clear();
    privateNotifications.clear();
    unreadCount = 0;
    _privateSubscription = null;
    isLoadingPublic = true;
    notifyListeners();
  }

  @override
  void dispose() {
    _privateSubscription?.cancel();
    super.dispose();
  }
}