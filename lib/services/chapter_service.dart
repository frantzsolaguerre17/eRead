import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/chapter.dart';

class ChapterService {
  final supabase = Supabase.instance.client;

  /// 🔹 Récupérer tous les chapitres d’un livre pour l’utilisateur connecté
  Future<List<Chapter>> getChaptersByBook(String bookId) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception("Utilisateur non authentifié");

    final response = await supabase
        .from('chapter')
        .select()
        .eq('book_id', bookId)
        .eq('user_id', user.id)
        .order('created_at', ascending: true);

    return (response as List)
        .map((json) => Chapter.fromJson(json))
        .toList();
  }

  /// 🔹 Ajouter un chapitre
  Future<void> addChapter(Chapter chapter) async {
    try {
      final response = await supabase.from('chapter').insert(chapter.toJson());

      if (response.error != null) {
        throw Exception(response.error!.message);
      }
    } catch (e) {
      throw Exception("Erreur insertion chapitre : $e");
    }
  }

  /// 🔹 Supprimer un chapitre
  Future<void> deleteChapter(String chapterId) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception("Utilisateur non authentifié");

    try {
      await supabase
          .from('chapter')
          .delete()
          .eq('id', chapterId)
          .eq('user_id', user.id);
    } catch (e) {
      throw Exception("Erreur suppression chapitre : $e");
    }
  }
}
