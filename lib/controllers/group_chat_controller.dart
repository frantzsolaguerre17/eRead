import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GroupChatController extends ChangeNotifier {
  final _supabase = Supabase.instance.client;

  List<Map<String, dynamic>> messages = [];
  StreamSubscription? _subscription;
  String? get currentUserId => _supabase.auth.currentUser?.id;
  bool _isListening = false;

  void startListening() {
    if (_subscription != null) return;

    _subscription = _supabase
        .from('group_messages')
        .stream(primaryKey: ['id'])
        .order('created_at')
        .listen((data) {
      messages = List<Map<String, dynamic>>.from(data);
      notifyListeners();
    });
  }

  Future<void> sendMessage(String text) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    await _supabase.from('group_messages').insert({
      'user_id': user.id,
      'username': user.email,
      'message': text,
    });
  }

  void reset() {
    messages.clear();
    _subscription?.cancel();
    _subscription = null;
    notifyListeners();
  }
}
