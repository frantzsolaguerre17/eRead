import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../controllers/expression_controller.dart';
import '../models/expression.dart';

class FavoriteExpressionScreen extends StatefulWidget {
  const FavoriteExpressionScreen({super.key});

  @override
  State<FavoriteExpressionScreen> createState() =>
      _FavoriteExpressionScreenState();
}

class _FavoriteExpressionScreenState
    extends State<FavoriteExpressionScreen> {
  final TextEditingController _searchController =
  TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context
          .read<ExpressionController>()
          .fetchFavoriteVocabulary();
    });
  }

  Future<void> _refreshFavorites() async {
    await context
        .read<ExpressionController>()
        .fetchFavoriteVocabulary();
  }

  @override
  Widget build(BuildContext context) {
    final controller =
    context.watch<ExpressionController>();

    /// 🔍 Filtrage
    final favoriteList = controller.expressions
        .where((exp) =>
    exp.isFavorite &&
        (exp.expressionText
            .toLowerCase()
            .contains(_searchQuery.toLowerCase()) ||
            exp.definition
                .toLowerCase()
                .contains(_searchQuery.toLowerCase())))
        .toList();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      // ================= APPBAR =================
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        title: const Text("Mes expressions favorites"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding:
            const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
              autocorrect: false,
              enableSuggestions: false,
              spellCheckConfiguration:
              SpellCheckConfiguration.disabled(),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText:
                "Rechercher une expression favorite...",
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
                    setState(() => _searchQuery = '');
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
          ? const FavoriteExpressionShimmer()
          : RefreshIndicator(
        onRefresh: _refreshFavorites,
        child: favoriteList.isEmpty
            ? const Center(
          child: Text(
            "Aucune expression favorite trouvée.",
            style: TextStyle(
                fontSize: 16,
                color: Colors.grey),
          ),
        )
            : ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: favoriteList.length,
          itemBuilder: (context, index) {
            final exp = favoriteList[index];

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
                          Icons.format_quote,
                          color:
                          Colors.deepPurple,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            exp.expressionText,
                            style:
                            const TextStyle(
                              fontSize: 18,
                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            exp.isFavorite
                                ? Icons.star
                                : Icons
                                .star_border,
                            color: Colors.amber,
                          ),
                          onPressed: () async {
                            await context
                                .read<
                                ExpressionController>()
                                .toggleFavorite(
                                exp);

                            await context
                                .read<
                                ExpressionController>()
                                .fetchFavoriteVocabulary();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Définition : ${exp.definition}",
                      style: const TextStyle(
                          fontSize: 16),
                    ),
                    if (exp.example.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        "Exemple : ${exp.example}",
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
class FavoriteExpressionShimmer extends StatelessWidget {
  const FavoriteExpressionShimmer({super.key});

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
