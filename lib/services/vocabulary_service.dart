import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/vocabulary.dart';

class VocabularyService {
  final SupabaseClient supabase = Supabase.instance.client;

  /// Ajouter un vocabulaire dans Supabase
  Future<Vocabulary> addVocabulary(Vocabulary vocab) async {
    try {
      final response = await supabase
          .from('vocabulary')
          .insert(vocab.toJson())
          .select()
          .single(); // récupère l'enregistrement inséré

      return Vocabulary.fromJson(response);
    } catch (e) {
      throw Exception('Erreur addVocabulary : $e');
    }
  }

  /// Récupérer tous les vocabulaires pour un livre
  Future<List<Vocabulary>> fetchVocabulary(String bookId) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return [];

      final response = await supabase
          .from('vocabulary')
          .select()
          .eq('book_id', bookId)
          .eq('user_id', user.id);

      if (response == null) return [];

      return (response as List)
          .map((json) => Vocabulary.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Erreur fetchVocabulary : $e');
    }
  }
}
