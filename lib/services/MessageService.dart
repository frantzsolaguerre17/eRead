import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationService {

  final SupabaseClient supabase = Supabase.instance.client;

  Future<List<Map<String,dynamic>>> fetchPrivateNotifications() async {

    final user = supabase.auth.currentUser;

    if(user == null) return [];

    final data = await supabase
        .from('notifications')
        .select()
        .eq('type', 'private_message')
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    return List<Map<String,dynamic>>.from(data);
  }


  Future<void> markAsRead(String id) async {

    await supabase
        .from('notifications')
        .update({'is_read': true})
        .eq('id', id);

  }

}