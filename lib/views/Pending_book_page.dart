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

  @override
  void initState() {
    super.initState();
    fetchPendingBooks();
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Livres en attente"),
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
            color: Theme.of(context).cardColor,
            elevation: 6,
            shadowColor: Theme.of(context).shadowColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            margin: const EdgeInsets.symmetric(vertical: 12),
            child: SizedBox(
              height: 160, // Hauteur du card fixe
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [

                  /// IMAGE DU LIVRE
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

                  /// INFOS LIVRE
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          book.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        Text(
                          "Auteur : ${book.author}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        Text("Pages : ${book.number_of_pages}"),

                        Text(
                          "Catégorie : ${book.category}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        Text(
                          "Ajouté par : ${book.user_name ?? 'Utilisateur'}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),


                  const SizedBox(width: 8),

                  /// BOUTONS VERTICAUX
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        width: 95,
                        child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center, // 👈 IMPORTANT
                          children: [
                            ElevatedButton(
                              onPressed: () => approveBook(book),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                minimumSize: const Size.fromHeight(32), // 👈 réduit la hauteur
                              ),
                              child: const Text("Approuver", style: TextStyle(fontSize: 11, color: Colors.white)),
                            ),
                            const SizedBox(height: 6),
                            ElevatedButton(
                              onPressed: () => rejectBook(book),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepOrange,
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                minimumSize: const Size.fromHeight(32),
                              ),
                              child: const Text("Refuser", style: TextStyle(fontSize: 11, color: Colors.white)),
                            ),
                            const SizedBox(height: 6),
                           /* OutlinedButton(
                              onPressed: () => downloadPdf(book),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                minimumSize: const Size.fromHeight(32),
                              ),
                              child: const Text("PDF", style: TextStyle(fontSize: 11)),
                            ),*/
                          ],
                        ),
                        )
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
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
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: 6,
      itemBuilder: (_, __) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Shimmer.fromColors(
            baseColor: Theme.of(context).dividerColor,
            highlightColor: Theme.of(context).highlightColor,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(12),
              ),
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius:
                  BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
