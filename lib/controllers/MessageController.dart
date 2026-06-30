import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/NotificationModel.dart';
import '../services/MessageService.dart';

class MessageController extends ChangeNotifier {

  final MessageService _service = MessageService();
  final _supabase = Supabase.instance.client;

  List<NotificationModel> notifications = [];

  bool isLoading = false;
  int unreadCount = 0;

  RealtimeChannel? _channel;

  MessageController() {
    _initRealtime();
  }


  /// REALTIME
  void _initRealtime() {

    final user = _supabase.auth.currentUser;

    if (user == null) return;

    _channel = _supabase
        .channel('private_notifications_${user.id}')

    /// INSERT
        .onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'notifications',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'user_id',
        value: user.id,
      ),
      callback: (payload) async {

        final newData = payload.newRecord;

        /// Seulement private_message
        if (newData['type'] == 'private_message') {

          /// Reload notifications
          await fetchNotifications();

          /// Reload badge
          await loadUnreadCount();
        }
      },
    )


    /// UPDATE
        .onPostgresChanges(
      event: PostgresChangeEvent.update,
      schema: 'public',
      table: 'notifications',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'user_id',
        value: user.id,
      ),
      callback: (payload) async {

        await fetchNotifications();

        if (payload.eventType == PostgresChangeEvent.insert) {
          final updatedData = payload.newRecord;

          if (updatedData['type'] == 'private_message') {
            await markAsRead(updatedData['id']);
            await fetchNotifications();
            await loadUnreadCount();
          }
        }
      },
    )

        .subscribe();
  }


  /// FETCH NOTIFICATIONS
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



  /// MARK AS READ
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

    await loadUnreadCount();

    notifyListeners();
  }


  /// LOAD UNREAD COUNT
  Future<void> loadUnreadCount() async {

    final user = _supabase.auth.currentUser;

    if(user == null) return;

    final data = await _supabase
        .from('notifications')
        .select()
        .eq('type', 'private_message')
        .eq('user_id', user.id)
        .eq('is_read', false);

    unreadCount = data.length;

    notifyListeners();
  }


  /// MARK ALL AS READ
  Future<void> markAllAsRead() async {

    final user = _supabase.auth.currentUser;

    if(user == null) return;

    await _supabase
        .from('notifications')
        .update({'is_read': true})
        .eq('type', 'private_message')
        .eq('user_id', user.id);

    notifications = notifications.map((n) {
      return NotificationModel(
        id: n.id,
        message: n.message,
        isRead: true,
        createdAt: n.createdAt,
      );
    }).toList();

    unreadCount = 0;

    notifyListeners();
  }


  void startListening() {

    final user = _supabase.auth.currentUser;

    if (user == null) return;

    /// éviter doublon
    _channel?.unsubscribe();

    _channel = _supabase.channel('private_notifications_$user');

    _channel!
        .onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'notifications',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'user_id',
        value: user.id,
      ),
      callback: (payload) async {

        /// recharge notifications
        await fetchNotifications();

        /// recharge badge
        await loadUnreadCount();
      },
    )
        .subscribe();
  }


  /// DISPOSE
  @override
  void dispose() {

    if (_channel != null) {
      _supabase.removeChannel(_channel!);
    }
    _channel?.unsubscribe();

    super.dispose();
  }
}