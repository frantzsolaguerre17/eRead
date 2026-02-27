import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GroupChatController extends ChangeNotifier {
  final _supabase = Supabase.instance.client;

  List<Map<String, dynamic>> messages = [];
  StreamSubscription? _subscription;
  //String? get currentUserId => _supabase.auth.currentUser?.id;
  bool _isListening = false;

  String? currentUserId;
  String? currentUsername;
  String? currentUserRole;


  void startListening() {
    if (_subscription != null) return;

    _subscription = _supabase
        .from('group_messages')
        .stream(primaryKey: ['id'])
        .order('created_at')
        .listen((data) {
      messages = data.map((e) => Map<String, dynamic>.from(e)).toList();
      notifyListeners();
    });
  }


  Future<void> sendMessage(String text) async {
    if (currentUserId == null) return;

    final newMessage = {
      'id': DateTime.now().millisecondsSinceEpoch, // temporaire
      'message': text,
      'user_id': currentUserId,
      'username': currentUsername,
      'role': currentUserRole,
      'created_at': DateTime.now().toIso8601String(),
    };

    /// ✅ 1. ajouter immédiatement à l'écran
    messages.add(newMessage);
    notifyListeners();

    /// ✅ 2. envoyer au serveur
    await _supabase.from('group_messages').insert({
      'message': text,
      'user_id': currentUserId,
      'username': currentUsername,
      'role': currentUserRole,
    });
  }


  Future<void> loadCurrentUser() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) return;

    currentUserId = user.id;

    final data = await Supabase.instance.client
        .from('profil')
        .select('username, role')
        .eq('user_id', user.id)
        .single();

    currentUsername = data['username'] ?? 'Utilisateur';
    currentUserRole = data['role'] ?? 'user';
  }


  void reset() {
    messages.clear();
    _subscription?.cancel();
    _subscription = null;
    notifyListeners();
  }
}
