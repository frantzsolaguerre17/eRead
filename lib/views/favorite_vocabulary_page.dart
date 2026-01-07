import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../controllers/vocabulary_controller.dart';
import '../models/vocabulary.dart';

class FavoriteVocabularyScreen extends StatefulWidget {
  const FavoriteVocabularyScreen({super.key});

  @override
  State<FavoriteVocabularyScreen> createState() =>
      _FavoriteVocabularyScreenState();
}

class _FavoriteVocabularyScreenState
    extends State<FavoriteVocabularyScreen> {
  final TextEditingController _searchController =
  TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context
          .read<VocabularyController>()
          .fetchFavoriteVocabulary();
    });
  }

  Future<void> _refreshFavorites() async {
    await context
        .read<VocabularyController>()
        .fetchFavoriteVocabulary();
  }

  @override
  Widget build(BuildContext context) {
    final controller =
    context.watch<VocabularyController>();

    // 🔍 Filtrage
    final favoriteList = controller.vocabularies
        .where((vocab) =>
    vocab.isFavorite &&
        (vocab.word
            .toLowerCase()
            .contains(_searchQuery.toLowerCase()) ||
            vocab.definition
                .toLowerCase()
                .contains(_searchQuery.toLowerCase())))
        .toList();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      // ================= APPBAR IDENTIQUE À FAVORIS LIVRES =================
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        title: const Text("Mes mots favoris"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding:
            const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              autocorrect: false,
              enableSuggestions: false,
              spellCheckConfiguration: SpellCheckConfiguration.disabled(),

              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Rechercher un mot favori...",
                hintStyle:
                const TextStyle(color: Colors.white70),
                prefixIcon: const Icon(Icons.search,
                    color: Colors.white70),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.close,
                      color: Colors.white70),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
                    : null,
                filled: true,
                fillColor: Colors.deepPurple.shade600,
                contentPadding:
                const EdgeInsets.symmetric(
                    vertical: 0, horizontal: 16),
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
      body: controller.isLoading
          ? const FavoriteVocabularyShimmer()
          : RefreshIndicator(
        onRefresh: _refreshFavorites,
        child: favoriteList.isEmpty
            ? const Center(
          child: Text(
            "Aucun mot favori trouvé.",
            style: TextStyle(
                fontSize: 16,
                color: Colors.grey),
          ),
        )
            : ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: favoriteList.length,
          itemBuilder: (context, index) {
            final vocab = favoriteList[index];

            return Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(
                  vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(12),
              ),
              child: Padding(
                padding:
                const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons
                              .lightbulb_outline,
                          color:
                          Colors.deepPurple,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            vocab.word,
                            style:
                            const TextStyle(
                              fontSize: 18,
                              fontWeight:
                              FontWeight
                                  .bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            vocab.isFavorite
                                ? Icons.star
                                : Icons
                                .star_border,
                            color:
                            Colors.amber,
                          ),
                          onPressed: () async {
                            final updated =
                            Vocabulary(
                              id: vocab.id,
                              word: vocab.word,
                              definition:
                              vocab.definition,
                              example:
                              vocab.example ??
                                  '',
                              createdAt:
                              vocab.createdAt,
                              bookId:
                              vocab.bookId,
                              userId:
                              vocab.userId,
                              isSynced: true,
                              isFavorite:
                              !vocab
                                  .isFavorite,
                            );

                            await context
                                .read<
                                VocabularyController>()
                                .updateVocabulary(
                                updated);

                            await context
                                .read<
                                VocabularyController>()
                                .fetchFavoriteVocabulary();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Définition : ${vocab.definition}",
                      style: const TextStyle(
                          fontSize: 16),
                    ),
                    if (vocab.example != null &&
                        vocab.example!
                            .trim()
                            .isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        "Exemple : ${vocab.example}",
                        style: const TextStyle(
                          fontSize: 15,
                          fontStyle:
                          FontStyle.italic,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ================= SHIMMER =================
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
            baseColor: Colors.deepPurple.shade50,
            highlightColor:
            Colors.deepPurple.shade100,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(12),
              ),
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade50,
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
