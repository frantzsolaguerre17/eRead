import 'package:flutter/material.dart';
import 'package:memo_livre/views/profil_page.dart';
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      // ================= APPBAR IDENTIQUE À FAVORIS LIVRES =================
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        title: Text("Mes mots favoris",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
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

              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              decoration: InputDecoration(
                hintText: "Rechercher un mot favori...",
                hintStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.7),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.7),
                ),
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
                fillColor: Theme.of(context).colorScheme.primary.withOpacity(0.8),
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

      // ================= BODY =================
      body: controller.isLoading
          ? const FavoriteVocabularyShimmer()
          : RefreshIndicator(
        onRefresh: _refreshFavorites,
        child: favoriteList.isEmpty
            ? Center(
          child: Text(
            "Aucun mot favori trouvé.",
            style: TextStyle(
                fontSize: 16,
              color: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.color
                  ?.withOpacity(0.6),),
          ),
        )
            : ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: favoriteList.length,
          itemBuilder: (context, index) {
            final vocab = favoriteList[index];

            return Card(
              color: Theme.of(context).cardColor,
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
                         Icon(
                          Icons
                              .lightbulb_outline,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            vocab.word,
                            style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
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
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (vocab.example != null &&
                        vocab.example!
                            .trim()
                            .isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        "Exemple : ${vocab.example}",
                        style: TextStyle(
                          fontSize: 15,
                          fontStyle:
                          FontStyle.italic,
                          color: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.color
                              ?.withOpacity(0.7),
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
