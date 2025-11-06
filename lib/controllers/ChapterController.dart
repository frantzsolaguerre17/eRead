import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/chapter.dart';

class ChapterController with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  final Map<String, List<Chapter>> _chaptersByBook = {};
  bool isLoading = false;
  final uuid = const Uuid();

  // 🔹 Récupérer les chapitres d’un livre
  Future<void> fetchChapters(String bookId) async {
    try {
      isLoading = true;
      notifyListeners();

      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final response = await _supabase
          .from('chapter')
          .select()
          .eq('book_id', bookId)
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final chapters = (response as List)
          .map((e) => Chapter.fromJson(e))
          .toList();

      _chaptersByBook[bookId] = chapters;
    } catch (e) {
      debugPrint("Erreur fetchChapters : $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // 🔹 Ajouter un chapitre
  Future<void> addChapter(String title, String bookId, String userId) async {
    try {
      final chapter = Chapter(
        id: uuid.v4(),
        title: title,
        createdAt: DateTime.now(),
        bookId: bookId,
        userId: userId,
        isSynced: true,
      );

      await _supabase.from('chapter').insert(chapter.toJson());

      _chaptersByBook.putIfAbsent(bookId, () => []);
      _chaptersByBook[bookId]!.insert(0, chapter);
      notifyListeners();
    } catch (e) {
      debugPrint("Erreur addChapter : $e");
      throw Exception("Erreur insertion chapitre");
    }
  }

  // 🔹 Supprimer un chapitre
  Future<void> deleteChapter(String chapterId, String bookId) async {
    try {
      await _supabase.from('chapter').delete().eq('id', chapterId);
      _chaptersByBook[bookId]?.removeWhere((c) => c.id == chapterId);
      notifyListeners();
    } catch (e) {
      debugPrint("Erreur deleteChapter : $e");
    }
  }

  // 🔹 Récupérer les chapitres d’un livre
  List<Chapter> getChapters(String bookId) {
    return _chaptersByBook[bookId] ?? [];
  }

  // 🔹 Vider les chapitres
  void clearChapters() {
    _chaptersByBook.clear();
    notifyListeners();
  }
}
