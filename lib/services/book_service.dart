import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/book.dart';

class BookService {
  final supabase = Supabase.instance.client;

  ///Ajouter un livre
  Future<void> addBook(Book book) async {
    await supabase.from('book').insert(book.toJson());
  }

  ///Récupérer tous les livres (sans username)
  Future<List<Book>> fetchBooks() async {
    final response = await supabase
        .from('book')
        .select()
        .eq('status', 'approved')
        .order('created_at', ascending: false);

    if (response == null) return [];

    return (response as List<dynamic>)
        .map((json) => Book.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  ///Récupérer les livres d’un utilisateur spécifique (sans username)
  Future<List<Book>> getBooksByUser(String userId) async {
    final response = await supabase
        .from('book')
        .select('*')
        .eq('user_id', userId);

    if (response == null) return [];

    return (response as List<dynamic>)
        .map((data) => Book.fromJson(data as Map<String, dynamic>))
        .toList();
  }


  ///Ajouter en favoris
  Future<void> addFavorite(String bookId) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    await supabase.from('favorites').insert({
      'user_id': user.id,
      'book_id': bookId,
    });
  }

  ///Retirer des favoris
  Future<void> removeFavorite(String bookId) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    await supabase
        .from('favorites')
        .delete()
        .eq('user_id', user.id)
        .eq('book_id', bookId);
  }

  ///Récupérer les favoris de l'utilisateur
  Future<List<String>> getUserFavorites() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return [];

    final res = await supabase
        .from('favorites')
        .select('book_id')
        .eq('user_id', user.id);

    return (res as List).map((e) => e['book_id'] as String).toList();
  }


  Future<List<Book>> fetchFavoriteBooks() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return [];

    // Récupérer les IDs des favoris
    final favRes = await supabase
        .from('favorites')
        .select('book_id')
        .eq('user_id', user.id);

    final List<String> favIds = (favRes as List)
        .map((e) => e['book_id'] as String)
        .toList();

    if (favIds.isEmpty) return [];

    final booksRes = await supabase
        .from('book')
        .select('*')
        .filter('id', 'in', favIds);

    return (booksRes as List)
        .map((json) => Book.fromJson(json as Map<String, dynamic>))
        .toList();
  }


  /// Met à jour la progression et le flag is_read
  Future<void> updateReadingProgress(String bookId, int progress, {bool? isRead}) async {
    final payload = <String, dynamic>{
      'reading_progress': progress,
    };

    if (isRead != null) {
      payload['is_read'] = isRead;
    }

    await supabase
        .from('book')
        .update(payload)
        .eq('id', bookId);
  }


  Future<int> getReadBooksCount() async {
    final user = supabase.auth.currentUser;
    if (user == null) return 0;

    try {
      final response = await supabase
          .from('user_book_progress')
          .select()
          .eq('user_id', user.id)
          .eq('is_read', true);

      if (response is List) {
        return response.length;
      } else {
        return 0;
      }
    } catch (e) {
      print('Erreur getReadBooksCount: $e');
      return 0;
    }
  }


}
