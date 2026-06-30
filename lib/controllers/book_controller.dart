import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/book.dart';
import '../models/userBookProgress.dart';
import '../services/book_service.dart';

class BookController extends ChangeNotifier {
  final BookService _service = BookService();

  List<Book> _books = [];
  bool isLoading = false;

  List<Book> get books => _books;

  List<String> favoriteBooks = [];
  final supabase = Supabase.instance.client;


  //Charger tous les livres
  Future<void> fetchBooks() async {
    isLoading = true;
    notifyListeners();

    try {
      _books = await _service.fetchBooks();

      //Charger les favoris depuis Supabase
      await loadFavorites();
    } catch (e) {
      debugPrint("Erreur fetchBooks: $e");
    }

    isLoading = false;
    notifyListeners();
  }


  //Ajouter un nouveau livre
  Future<void> addBook(
      Book newBook, {
        required String title,
        required String author,
        String numberOfPages = '',
        String cover = '',
        String pdf = '',
        String category = 'Autre',
      }) async {
    final supabase = Supabase.instance.client;

    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        throw Exception("Utilisateur non connecté");
      }

      await supabase.from('book').insert(newBook.toJson());

    } catch (e) {
      debugPrint("Erreur addBook controller: $e");
      rethrow;
    }
  }




  ///FAVORIS

  //Charger les favoris depuis Supabase
  Future<void> loadFavorites() async {
    try {
      favoriteBooks = await _service.getUserFavorites();
    } catch (e) {
      debugPrint("Erreur loadFavorites: $e");
    }
    notifyListeners();
  }


  //Ajouter / Retirer un favori
  Future<void> toggleFavorite(String bookId) async {
    try {
      final isFavorite = favoriteBooks.contains(bookId);

      if (isFavorite) {
        await _service.removeFavorite(bookId);
        favoriteBooks.remove(bookId);
      } else {
        await _service.addFavorite(bookId);
        favoriteBooks.add(bookId);
      }

    } catch (e) {
      debugPrint("Erreur toggleFavorite: $e");
    }

    notifyListeners();
  }


  //Vérifier si un livre est favori
  bool isFavorite(String bookId) {
    return favoriteBooks.contains(bookId);
  }


  // Met à jour la progression d'un livre (localement et en DB)
  Future<UserBookProgress?> getProgress(String bookId) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return null;

    final data = await supabase
        .from('user_book_progress')
        .select()
        .eq('user_id', userId)
        .eq('book_id', bookId)
        .maybeSingle();

    if (data != null) {
      return UserBookProgress.fromMap(data);
    }
    return null;
  }


  Future<void> updateReadingProgress(String bookId, int progress, {bool? isRead}) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    final payload = {
      'user_id': userId,
      'book_id': bookId,
      'reading_progress': progress,
    };
    if (isRead != null) payload['is_read'] = isRead;

    try {
      await supabase
          .from('user_book_progress')
          .upsert(payload, onConflict: 'user_id,book_id');

      int index = books.indexWhere((b) => b.id == bookId);
      if (index != -1) {
        books[index].readingProgress = progress;
        if (isRead != null) books[index].isRead = isRead;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Erreur updateReadingProgress: $e');
    }
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


  void addLocalBook(Book book) {
    _books.insert(0, book);
    notifyListeners();
  }

}


