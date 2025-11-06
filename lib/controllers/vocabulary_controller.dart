import 'package:flutter/material.dart';
import '../models/vocabulary.dart';
import '../services/vocabulary_service.dart';

class VocabularyController extends ChangeNotifier {
  final VocabularyService service = VocabularyService();

  List<Vocabulary> _vocabularies = [];
  bool isLoading = false;

  List<Vocabulary> get vocabularies => _vocabularies;

  /// Récupérer les vocabulaires depuis Supabase
  Future<void> fetchVocabulary(String bookId) async {
    try {
      isLoading = true;
      notifyListeners();

      final fetched = await service.fetchVocabulary(bookId);
      _vocabularies = fetched;
    } catch (e) {
      debugPrint('Erreur fetchVocabulary : $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Ajouter un vocabulaire dans Supabase et mettre à jour la liste locale
  Future<void> addVocabulary(Vocabulary vocab) async {
    try {
      final inserted = await service.addVocabulary(vocab);
      _vocabularies.add(inserted);
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur addVocabulary : $e');
      throw Exception('Erreur insertion vocabulary');
    }
  }
}
