import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../controllers/book_controller.dart';
import '../models/book.dart';
import '../models/userBookProgress.dart';
import '../services/book_service.dart';
import 'AddBook_page.dart';
import 'pdf_viewer_page.dart';
import 'favorites_book_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BookListPage extends StatefulWidget {
  const BookListPage({super.key});

  @override
  State<BookListPage> createState() => _BookListPageState();
}

class _BookListPageState extends State<BookListPage> {
  List<Book> books = [];
  List<Book> filteredBooks = [];

  final List<String> categories = [
    'Toutes',
    'Biographie',
    'Développement Personnel',
    'Économie / Finance',
    'Histoire',
    'Philosophie',
    'Psychologie',
    'Roman',
    'Science / Technologie',
    'Spiritualité / Religion',
    'Autre',
  ];

  String selectedCategory = 'Toutes';
  bool isLoading = true;
  String searchQuery = '';

  final TextEditingController _searchController = TextEditingController();
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    setState(() => isLoading = true);
    final data = await BookService().fetchBooks();
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      books = data;
      filteredBooks = books;
      isLoading = false;
    });
  }

  void _filterBooks(String query) {
    searchQuery = query;
    _applyFilters();
  }

  void _filterByCategory(String category) {
    selectedCategory = category;
    _applyFilters();
  }

  void _applyFilters() {
    List<Book> results = books;

    if (selectedCategory != 'Toutes') {
      results =
          results.where((b) => b.category == selectedCategory).toList();
    }

    if (searchQuery.isNotEmpty) {
      results = results
          .where((b) =>
          b.title.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    }

    setState(() => filteredBooks = results);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      // ===================== APPBAR =====================
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        elevation: 4,
        title: const Text(
          "Mes livres",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: _filterBooks,
              autocorrect: false,
              enableSuggestions: false,
              spellCheckConfiguration: SpellCheckConfiguration.disabled(),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Rechercher un livre...",
                hintStyle: const TextStyle(color: Colors.white70),
                prefixIcon:
                const Icon(Icons.search, color: Colors.white70),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.close,
                      color: Colors.white70),
                  onPressed: () {
                    setState(() {
                      searchQuery = '';
                      _searchController.clear();
                    });
                    _filterBooks('');
                  },
                )
                    : null,
                filled: true,
                fillColor: Colors.deepPurple.shade600,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite, color: Colors.redAccent),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const FavoriteBooksPage()),
              );
            },
          )
        ],
      ),
      // =================================================

      body: isLoading
          ? const BookListShimmer()
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 8),
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: Colors.deepPurple.shade200),
              ),
              child: DropdownButton<String>(
                value: selectedCategory,
                isExpanded: true,
                underline: const SizedBox(),
                icon: const Icon(Icons.arrow_drop_down,
                    color: Colors.deepPurple),
                items: categories
                    .map(
                      (c) => DropdownMenuItem(
                    value: c,
                    child: Text(c),
                  ),
                )
                    .toList(),
                onChanged: (v) {
                  if (v != null) _filterByCategory(v);
                },
              ),
            ),
          ),
          Expanded(
            child: filteredBooks.isEmpty
                ? const Center(
                child: Text(
                  "Aucun livre trouvé.",
                  style: TextStyle(color: Colors.grey),
                ))
                : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: filteredBooks.length,
              itemBuilder: (context, index) {
                return ModernBookCard(
                    book: filteredBooks[index]);
              },
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.deepPurple,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
        ),
        icon: Row(
          children: const [
            Icon(Icons.add, color: Colors.white),
            SizedBox(width: 4),
            Icon(Icons.menu_book, color: Colors.white),
          ],
        ),
        label: const SizedBox(), // Pas de texte
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddBookPage()),
          );

          if (result == true) {
            Provider.of<BookController>(context, listen: false).fetchBooks();
          }
        },
      ),


    );
  }
}

// ================= SHIMMER =================
class BookListShimmer extends StatelessWidget {
  const BookListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: 6,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Shimmer.fromColors(
          baseColor: Colors.deepPurple.shade50,
          highlightColor: Colors.deepPurple.shade100,
          child: Container(
            height: 160,
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),
    );
  }
}

// ================= CARTE LIVRE =================
class ModernBookCard extends StatefulWidget {
  final Book book;
  const ModernBookCard({required this.book, super.key});

  @override
  State<ModernBookCard> createState() => _ModernBookCardState();
}

class _ModernBookCardState extends State<ModernBookCard> {
  bool isFavorite = false;
  double progress = 0;
  bool isNewBook = false;
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _loadFavoriteStatus();
    _loadProgress();
    _checkIfNew();
  }

  Future<void> _loadFavoriteStatus() async {
    final favs = await BookService().getUserFavorites();
    setState(() => isFavorite = favs.contains(widget.book.id));
  }

  Future<void> _toggleFavorite() async {
    isFavorite
        ? await BookService().removeFavorite(widget.book.id)
        : await BookService().addFavorite(widget.book.id);
    setState(() => isFavorite = !isFavorite);
  }

  Future<void> _loadProgress() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final data = await supabase
        .from('user_book_progress')
        .select()
        .eq('user_id', user.id)
        .eq('book_id', widget.book.id)
        .maybeSingle();

    if (data != null) {
      final p = UserBookProgress.fromMap(data);
      setState(() => progress = (p.readingProgress / 100).clamp(0.0, 1.0));
    }
  }

  Future<void> _checkIfNew() async {
    final createdAt = widget.book.createdAt; // DateTime
    if (createdAt != null) {
      final diff = DateTime.now().difference(createdAt);
      setState(() => isNewBook = diff.inDays <= 7);
    }
  }

  Color _getBadgeColor() {
    if (progress >= 0.8) return Colors.green;
    if (progress > 0) return Colors.blue;
    return Colors.grey;
  }

  String _getBadgeText() {
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
                builder: (_) => PdfViewerPage(book: widget.book)),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("PDF non disponible pour ce livre")),
          );
        }
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 6,
        child: SizedBox(
          height: 160,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(20),
                ),
                child: widget.book.cover.startsWith('http')
                    ? Image.network(
                  widget.book.cover,
                  width: 120,
                  height: 160,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Image.asset(
                    "assets/images/default_image.png",
                    width: 120,
                    height: 160,
                    fit: BoxFit.cover,
                  ),
                )
                    : Image.asset(
                  widget.book.cover.isNotEmpty
                      ? widget.book.cover
                      : "assets/images/default_image.png",
                  width: 120,
                  height: 160,
                  fit: BoxFit.cover,
                ),
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Stack(
                    children: [
                      SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.book.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              "Auteur : ${widget.book.author}",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),

                            Text("Pages : ${widget.book.number_of_pages}"),

                            Text(
                              "Catégorie : ${widget.book.category}",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),

                            const SizedBox(height: 4),

                            Text(
                              "Ajouté par : ${widget.book.user_name}",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                              ),
                            ),

                            if (isNewBook)
                              Container(
                                margin: const EdgeInsets.only(top: 6),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  "NOUVEAU",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      // Boutons favoris + badge
                      Positioned(
                        right: 0,
                        top: 30,
                        child: Column(
                          children: [
                            IconButton(
                              icon: Icon(
                                isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: Colors.red,
                              ),
                              onPressed: _toggleFavorite,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getBadgeColor(),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _getBadgeText(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
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
}