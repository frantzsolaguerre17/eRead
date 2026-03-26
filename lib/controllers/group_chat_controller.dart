import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class GroupChatController extends ChangeNotifier {
  final _supabase = Supabase.instance.client;

  List<Map<String, dynamic>> messages = [];
  String? currentUserId;
  String? currentUserName;
  String? currentUserRole;

  StreamSubscription<List<Map<String, dynamic>>>? _subscription;

  /// Charger l'utilisateur courant
  Future<void> loadCurrentUser() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;
    currentUserId = user.id;

    // On peut récupérer username et role depuis la table users si tu as ces champs
    final data = await _supabase
        .from('users_profile') // table custom avec username/role
        .select()
        .eq('id', user.id)
        .maybeSingle();

    currentUserName = data?['username'] ?? 'Utilisateur';
    currentUserRole = data?['role'] ?? 'user';

    notifyListeners();
  }

  /// Stream temps réel
  void startListening() {
    _subscription = _supabase
        .from('group_messages')
        .stream(primaryKey: ['id'])
        .listen((updates) {
      // ⚡ updates = List<Map<String,dynamic>> contenant les changements
      for (var change in updates) {
        final index = messages.indexWhere((m) => m['id'] == change['id']);
        if (index != -1) {
          messages[index] = change; // update existant
        } else {
          messages.add(change); // nouveau message
        }
      }
      messages.sort((a, b) =>
          DateTime.parse(a['created_at'])
              .compareTo(DateTime.parse(b['created_at'])));

      notifyListeners();
    });
  }

  /// Envoyer un message
  Future<void> sendMessage(String text) async {
    if (currentUserId == null) return;

    final newMessage = {
      'id': const Uuid().v4(), // temporaire
      'user_id': currentUserId,
      'username': currentUserName,
      'role': currentUserRole ?? 'user',
      'message': text,
      'created_at': DateTime.now().toIso8601String(),
    };

    messages.add(newMessage);
    notifyListeners(); // affichage instantané

    // envoi au serveur
    await _supabase.from('group_messages').insert({
      'user_id': currentUserId,
      'username': currentUserName,
      'role': currentUserRole ?? 'user',
      'message': text,
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    //controller.dispose();
    //scrollController.dispose();
    super.dispose();
  }
}