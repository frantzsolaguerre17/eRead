import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/book.dart';
import '../models/userBookProgress.dart';
import '../services/book_service.dart';
import 'pdf_viewer_page.dart';

class FavoriteBooksPage extends StatefulWidget {
  const FavoriteBooksPage({super.key});

  @override
  State<FavoriteBooksPage> createState() => _FavoriteBooksPageState();
}

class _FavoriteBooksPageState extends State<FavoriteBooksPage> {
  List<Book> allFavorites = [];
  List<Book> filteredFavorites = [];
  bool isLoading = true;

  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() => isLoading = true);

    final data = await BookService().fetchFavoriteBooks();
    await Future.delayed(const Duration(milliseconds: 300));

    setState(() {
      allFavorites = data;
      filteredFavorites = data;
      isLoading = false;
    });
  }

  void _filterFavorites(String query) {
    searchQuery = query.toLowerCase();
    setState(() {
      filteredFavorites = allFavorites.where((book) {
        return book.title.toLowerCase().contains(searchQuery) ||
            book.author.toLowerCase().contains(searchQuery) ||
            book.category.toLowerCase().contains(searchQuery);
      }).toList();
    });
  }

  Future<void> _removeFavorite(Book book) async {
    await BookService().removeFavorite(book.id);

    setState(() {
      allFavorites.removeWhere((b) => b.id == book.id);
      filteredFavorites.removeWhere((b) => b.id == book.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      // ================= APPBAR AVEC RECHERCHE =================
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        title: Text("Mes livres favoris",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: _filterFavorites,
              autocorrect: false,
              enableSuggestions: false,
              spellCheckConfiguration: SpellCheckConfiguration.disabled(),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              decoration: InputDecoration(
                hintText: "Rechercher un livre favori...",
                hintStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.7),
                ),
                prefixIcon:
                 Icon(
                  Icons.search,
                  color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.7),
                ),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.close,
                      color: Colors.white70),
                  onPressed: () {
                    _searchController.clear();
                    _filterFavorites('');
                  },
                )
                    : null,
                filled: true,
                fillColor: Theme.of(context).colorScheme.primary.withOpacity(0.8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),

      // ================= BODY =================
      body: isLoading
          ? const FavoriteShimmer()
          : filteredFavorites.isEmpty
          ? Center(
        child: Text(
          "Aucun livre favori trouvé.",
          style:
          TextStyle(fontSize: 16, color: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.color
              ?.withOpacity(0.6),),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: filteredFavorites.length,
        itemBuilder: (context, index) {
          final book = filteredFavorites[index];
          return FavoriteModernBookCard(
            book: book,
            onRemove: () => _removeFavorite(book),
          );
        },
      ),
    );
  }
}

//
// ================= SHIMMER =================
//
class FavoriteShimmer extends StatelessWidget {
  const FavoriteShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: 6,
      itemBuilder: (_, __) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Shimmer.fromColors(

          baseColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
          highlightColor: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
            child: Card(
              color: Theme.of(context).cardColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Container(
                height: 160,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

//
// ================= CARD FAVORI AVEC BADGE PROGRESSION =================
//
class FavoriteModernBookCard extends StatefulWidget {
  final Book book;
  final VoidCallback onRemove;

  const FavoriteModernBookCard({
    super.key,
    required this.book,
    required this.onRemove,
  });

  @override
  State<FavoriteModernBookCard> createState() =>
      _FavoriteModernBookCardState();
}

class _FavoriteModernBookCardState
    extends State<FavoriteModernBookCard> {
  static const double cardHeight = 160;
  double progress = 0;

  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final response = await supabase
        .from('user_book_progress')
        .select()
        .eq('user_id', user.id)
        .eq('book_id', widget.book.id)
        .maybeSingle();

    if (response != null) {
      final data = UserBookProgress.fromMap(response);
      setState(() {
        progress = (data.readingProgress / 100).clamp(0.0, 1.0);
      });
    }
  }

  Color _badgeColor() {
    if (progress >= 0.8) return Colors.green;
    if (progress > 0) return Theme.of(context).colorScheme.primary;
    return Theme.of(context).colorScheme.outline;
  }

  String _badgeText() {
    if (progress >= 0.8) return "LU";
    return "${(progress * 100).round()}%";
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.book.pdf.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  PdfViewerPage(book: widget.book),
            ),
          );
        }
      },
      child: Card(
        color: Theme.of(context).cardColor,
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 6,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        child: SizedBox(
          height: cardHeight,
          child: Row(
            children: [
              // IMAGE
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
                child: widget.book.cover.isNotEmpty
                    ? Image.network(
                  widget.book.cover,
                  width: 120,
                  height: cardHeight,
                  fit: BoxFit.cover,
                )
                    : _defaultCover(),
              ),

              // TEXTE
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Stack(
                    children: [
                      Column(
                        mainAxisAlignment:
                        MainAxisAlignment.center,
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.book.title,
                            maxLines: 2,
                            overflow:
                            TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            )
                          ),
                          const SizedBox(height: 4),
                          Text(
                              "Auteur : ${widget.book.author}",
                              style: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.color
                                    ?.withOpacity(0.7),)),
                          Text(
                              "Pages : ${widget.book.number_of_pages}",
                              style: TextStyle(
                                  color: Colors
                                      .grey.shade700)),
                          Text(
                              "Catégorie : ${widget.book.category}",
                              style: TextStyle(
                                  color: Colors
                                      .grey.shade700)),
                        ],
                      ),

                      // FAVORI + BADGE
                      Positioned(
                        right: 0,
                        top: 50,
                        child: Column(
                          children: [
                            IconButton(
                              icon: const Icon(
                                  Icons.favorite,
                                  color: Colors.red),
                              onPressed: widget.onRemove,
                            ),
                            Container(
                              padding:
                              const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4),
                              decoration: BoxDecoration(
                                color: _badgeColor(),
                                borderRadius:
                                BorderRadius.circular(
                                    20),
                              ),
                              child: Text(
                                _badgeText(),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight:
                                    FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _defaultCover() {
    return Container(
      width: 120,
      height: cardHeight,
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: const Icon(Icons.book, size: 50),
    );
  }
}
