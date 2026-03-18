import 'package:supabase_flutter/supabase_flutter.dart';

class PublicNotificationService {

  final supabase = Supabase.instance.client;


  Future<List<Map<String, dynamic>>> fetchNotifications() async {

    final data = await supabase
        .from('notifications')
        .select()
        .eq('type', 'book_added')
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(data);
  }


  Future<int> getUnreadCount() async {

    final data = await supabase
        .from('notifications')
        .select('id')
        .eq('type', 'book_added')
        .eq('is_read', false);

    return data.length;
  }

  Future<int> loadUnreadCount() async {

    final user = supabase.auth.currentUser;

    final count = await supabase.rpc(
      'get_unread_public_notifications',
      params: {'user_uuid': user!.id},
    );

    return count ?? 0;
  }

  Future<void> markAllAsRead() async {

    await supabase
        .from('notifications')
        .update({'is_read': true})
        .eq('type', 'book_added')
        .eq('is_read', false);

  }

}