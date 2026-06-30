import 'package:supabase_flutter/supabase_flutter.dart';

class BookmarkService {

  static Future<int> getBookmarkPage(String bookId) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return 1;

      final res = await Supabase.instance.client
          .from('bookmarks')
          .select('page_number')
          .eq('book_id', bookId)
          .eq('user_id', user.id)
          .maybeSingle();

      return (res?['page'] as int?) ?? 1;

    } catch (e) {
      print("Bookmark error: $e");
      return 1;
    }
  }
}