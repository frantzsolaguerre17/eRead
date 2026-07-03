import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/vocabulary.dart';

class VocabularyService {
  final SupabaseClient supabase = Supabase.instance.client;

  ///Ajouter un vocabulaire
  Future<Vocabulary> addVocabulary(Vocabulary vocab) async {
    final res = await supabase
        .from('vocabulary')
        .insert(vocab.toJson())
        .select()
        .single();
    return Vocabulary.fromJson(res);
  }

  ///Récupérer les vocabulaires du livre pour l'utilisateur actuel
  Future<List<Vocabulary>> fetchVocabulary(String bookId) async {
    final user = supabase.auth.currentUser;
    if (user == null) return [];

    final response = await supabase
        .from('vocabulary')
        .select()
        .eq('book_id', bookId)
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => Vocabulary.fromJson(json))
        .toList();
  }


  ///Supprimer
  Future<void> deleteVocabulary(String id) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    await supabase
        .from('vocabulary')
        .delete()
        .eq('id', id)
        .eq('user_id', user.id); // RLS : ne peut supprimer que ses propres mots
  }


  ///Modifier un vocabulaire
  Future<void> updateVocabulary(Vocabulary vocab) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    await supabase
        .from('vocabulary')
        .update(vocab.toJson())
        .eq('id', vocab.id)
        .eq('user_id', user.id); // RLS : ne peut modifier que ses propres mots
  }

  ///Favoris
  Future<void> toggleFavorite(String id, bool newValue) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    await supabase
        .from('vocabulary')
        .update({'is_favorite': newValue})
        .eq('id', id)
        .eq('user_id', user.id); // RLS : ne peut changer que ses propres mots
  }

  ///Compter les mots appris par l'utilisateur
  Future<int> getLearnedWordsCount() async {
    final userId = Supabase.instance.client.auth.currentUser!.id;
    final res = await supabase
        .from('vocabulary')
        .select('*')
        .eq('user_id', userId)
        .count();

    return res.count ?? 0;
  }

}
