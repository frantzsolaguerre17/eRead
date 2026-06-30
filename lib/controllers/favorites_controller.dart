import 'package:supabase_flutter/supabase_flutter.dart';

class FavoriteController {
  final SupabaseClient supabase = Supabase.instance.client;

  /// Ajouter un livre en favoris
  Future<bool> addFavorite(String bookId) async {
    final user = supabase.auth.currentUser;
    if (user == null) return false;

    try {
      await supabase.from('favorites').insert({
        'user_id': user.id,
        'book_id': bookId,
      });
      return true;
    } catch (e) {
      print("Erreur addFavorite: $e");
      return false;
    }
  }


  //Retirer un livre des favoris
  Future<bool> removeFavorite(String bookId) async {
    final user = supabase.auth.currentUser;
    if (user == null) return false;

    try {
      await supabase
          .from('favorites')
          .delete()
          .match({'user_id': user.id, 'book_id': bookId});
      return true;
    } catch (e) {
      print("Erreur removeFavorite: $e");
      return false;
    }
  }


  // Vérifier si un livre est favori
  Future<bool> isFavorite(String bookId) async {
    final user = supabase.auth.currentUser;
    if (user == null) return false;

    try {
      final result = await supabase
          .from('favorites')
          .select()
          .match({'user_id': user.id, 'book_id': bookId});

      return result.isNotEmpty;
    } catch (e) {
      print("Erreur isFavorite: $e");
      return false;
    }
  }


  /// Récupérer tous les favoris de l'utilisateur
  Future<List<String>> getFavorites() async {
    final user = supabase.auth.currentUser;
    if (user == null) return [];

    try {
      final result = await supabase
          .from('favorites')
          .select('book_id')
          .eq('user_id', user.id);

      return result.map<String>((row) => row['book_id']).toList();
    } catch (e) {
      print("Erreur getFavorites: $e");
      return [];
    }
  }
}
