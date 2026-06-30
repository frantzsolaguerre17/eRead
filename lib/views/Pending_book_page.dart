import 'package:flutter/material.dart';
import 'package:memo_livre/views/Pending_Book_Detail_Screen.dart';
import 'package:memo_livre/views/profil_page.dart';
import 'package:shimmer/shimmer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/book.dart';

class AdminPendingBooksScreen extends StatefulWidget {
  const AdminPendingBooksScreen({super.key});

  @override
  State<AdminPendingBooksScreen> createState() => _AdminPendingBooksScreenState();
}

class _AdminPendingBooksScreenState extends State<AdminPendingBooksScreen> {
  final supabase = Supabase.instance.client;
  List<Book> pendingBooks = [];
  bool isLoading = true;
  RealtimeChannel? _pendingBooksChannel;

  @override
  void initState() {
    super.initState();
    fetchPendingBooks();

    /// ✅ REALTIME PENDING BOOKS
    _pendingBooksChannel = supabase
        .channel('pending-books-realtime')
        .onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'book',
      callback: (payload) async {

        final data = payload.newRecord;

        /// seulement livres pending
        if (data['status'] == 'pending') {
          await fetchPendingBooks();
        }

        /// quand approuvé/refusé aussi
        if (payload.eventType == PostgresChangeEvent.update) {
          await fetchPendingBooks();
        }
      },
    )
        .subscribe();

  }

  Future<void> fetchPendingBooks() async {
    setState(() => isLoading = true);

    try {
      final data = await supabase
          .from('book')
          .select()
          .eq('status', 'pending')
          .order('created_at', ascending: false);

      pendingBooks = List<Book>.from(
        data.map((item) => Book.fromJson(item)),
      );
    } catch (e) {
      debugPrint("Erreur fetchPendingBooks: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  // ✅ Approuver un livre
  Future<void> approveBook(Book book) async {
    try {
      await supabase.from('book').update({'status': 'approved'}).eq('id', book.id);
      _showSnack("Livre approuvé ✅");
      fetchPendingBooks();
    } catch (e) {
      _showSnack("Erreur lors de l'approbation: $e");
    }
  }

  // ❌ Refuser un livre
  Future<void> rejectBook(Book book) async {
    try {
      await supabase.from('book').update({'status': 'rejected'}).eq('id', book.id);
      _showSnack("Livre refusé ❌");
      fetchPendingBooks();
    } catch (e) {
      _showSnack("Erreur lors du refus: $e");
    }
  }

  // ❌ Refuser un livre


  // 📥 Télécharger le PDF
  Future<void> downloadPdf(Book book) async {
    if (book.pdf.isEmpty) {
      _showSnack("Pas de PDF disponible");
      return;
    }

    final url = book.pdf;
    // Ici tu peux utiliser `url_launcher` pour ouvrir le PDF dans le navigateur ou le télécharger
    // ex: launchUrl(Uri.parse(url));
    _showSnack("PDF disponible ici: $url");
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    _pendingBooksChannel?.unsubscribe();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Livres en attente", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
              icon: const Icon(Icons.account_circle, color: Colors.white),
              tooltip: "Account profil",
              onPressed: () async{
                await Navigator.push(context,
                    MaterialPageRoute(
                        builder: (context) => const ProfilePage()
                    )
                );
              }
          ),
        ],
      ),
      body: isLoading
          ? const FavoriteVocabularyShimmer()
          : pendingBooks.isEmpty
          ? Center(
        child: Text(
          "Aucun livre en attente",
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: pendingBooks.length,
        itemBuilder: (_, index) {
          final book = pendingBooks[index];

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PendingBookDetailScreen(
                    book: book,
                    onApprove: approveBook,
                    onReject: rejectBook,
                  ),
                ),

              );
            },

        child: Card(
           // color: Theme.of(context).cardColor,
            elevation: isDark ? 2 : 6,
            shadowColor: Theme.of(context).shadowColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            margin: const EdgeInsets.symmetric(vertical: 12),
            child: SizedBox(
              height: 160,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [

                  /// IMAGE
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                    child: book.cover.isNotEmpty
                        ? (book.cover.startsWith('http')
                        ? Image.network(
                      book.cover,
                      width: 110,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    )
                        : Image.asset(
                      "assets/images/default_image.png",
                      width: 110,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ))
                        : Image.asset(
                      "assets/images/default_image.png",
                      width: 110,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),

                  const SizedBox(width: 12),

                  /// INFOS
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                        Text(
                          book.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          "Auteur : ${book.author}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),

                        Text(
                          "Pages : ${book.number_of_pages}",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),

                        Text(
                          "Catégorie : ${book.category}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),

                        Text(
                          "Ajouté par : ${book.user_name ?? 'Utilisateur'}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontStyle: FontStyle.italic,
                            color: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.color
                                ?.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// BOUTONS
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                        ElevatedButton(
                          onPressed: () => approveBook(book),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark
                                ? Colors.green.shade700
                                : Colors.green,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(80, 32),
                            padding: const EdgeInsets.symmetric(vertical: 6),
                          ),
                          child: const Text(
                            "Approuver",
                            style: TextStyle(fontSize: 11),
                          ),
                        ),

                        const SizedBox(height: 6),

                        ElevatedButton(
                          onPressed: () => rejectBook(book),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark
                                ? Colors.deepOrange.shade700
                                : Colors.deepOrange,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(80, 32),
                            padding: const EdgeInsets.symmetric(vertical: 6),
                          ),
                          child: const Text(
                            "Refuser",
                            style: TextStyle(fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
          );
        },
      ),
    );
  }

}


class FavoriteVocabularyShimmer extends StatelessWidget {
  const FavoriteVocabularyShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: 6,
      itemBuilder: (_, __) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Shimmer.fromColors(
            baseColor: isDark
                ? Colors.grey[800]!
                : Colors.grey[300]!,
            highlightColor: isDark
                ? Colors.grey[700]!
                : Colors.grey[100]!,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 16,
                      width: double.infinity,
                      color: theme.cardColor,
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 14,
                      width: 200,
                      color: theme.cardColor,
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 14,
                      width: 150,
                      color: theme.cardColor,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

}


