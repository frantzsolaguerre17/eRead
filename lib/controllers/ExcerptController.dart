import 'package:flutter/material.dart';
import '../models/excerpt.dart';
import '../services/excerpt_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ExcerptController extends ChangeNotifier {
  final ExcerptService _service = ExcerptService();
  final SupabaseClient supabase = Supabase.instance.client;

  Map<String, List<Excerpt>> _excerpts = {};
  bool isLoading = false;

  List<Excerpt> getExcerpts(String chapterId) =>
      _excerpts[chapterId] ?? [];


  void clearExcerpts() {
    _excerpts.clear();
    notifyListeners();
  }


  Future<void> fetchExcerpts(String chapterId) async {
    try {
      isLoading = true;
      notifyListeners();

      final fetched = await _service.fetchExcerpts(chapterId);
      _excerpts[chapterId] = fetched;
    } catch (e) {
      debugPrint('Erreur fetchExcerpts : $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }


  Future<void> addExcerpt(String chapterId, String content, String comment) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      final newExcerpt = Excerpt(
        id: '',
        chapterId: chapterId,
        content: content,
        comment: comment,
        createdAt: DateTime.now(),
        isSynced: true,
      );

      final inserted = await _service.addExcerpt(newExcerpt, user.id);

      _excerpts.putIfAbsent(chapterId, () => []);
      _excerpts[chapterId]!.add(inserted);
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur addExcerpt : $e');
      throw Exception('Erreur insertion extrait');
    }
  }


  Future<void> updateExcerpt(String id, String content, String? comment) async {
    final response = await supabase
        .from('excerpt')
        .update({'content': content, 'comment': comment})
        .eq('id', id)
        .select();

    if (response != null && response.isNotEmpty) {
      _excerpts.forEach((chapterId, excerpts) {
        final index = excerpts.indexWhere((ex) => ex.id == id);
        if (index != -1) {
          excerpts[index].content = content;
          excerpts[index].comment = comment;
        }
      });
      notifyListeners();
    }
  }


  Future<void> deleteExcerpt(String id, String chapterId) async {
    await supabase
        .from('excerpt')
        .delete()
        .eq('id', id);

    _excerpts[chapterId]?.removeWhere((ex) => ex.id == id);
    notifyListeners();
  }

}
