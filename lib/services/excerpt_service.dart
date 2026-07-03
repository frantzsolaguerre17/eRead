import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/excerpt.dart';

class ExcerptService {
  final supabase = Supabase.instance.client;

  ///Ajouter un extrait dans la base de données
  Future<Excerpt> addExcerpt(Excerpt excerpt, String userId) async {
    try {
      final response = await supabase
          .from('excerpt')
          .insert({
        'chapter_id': excerpt.chapterId,
        'content': excerpt.content,
        'comment': excerpt.comment,
        'created_at': excerpt.createdAt.toIso8601String(),
        'isSynced': excerpt.isSynced,
        'user_id': userId,
      })
          .select()
          .single();

      return Excerpt.fromJson(response);
    } catch (e) {
      throw Exception('Erreur addExcerpt : $e');
    }
  }


  ///Récupérer les extraits d’un chapitre
  Future<List<Excerpt>> fetchExcerpts(String chapterId) async {
    try {
      final userId = supabase.auth.currentUser!.id;

      final response = await supabase
          .from('excerpt')
          .select()
          .eq('chapter_id', chapterId)
          .eq('user_id', userId);

      if (response == null) return [];

      final excerpts = (response as List)
          .map((json) => Excerpt.fromJson(json))
          .toList();

      return excerpts;
    } catch (e) {
      throw Exception('Erreur fetchExcerpts : $e');
    }
  }
}
