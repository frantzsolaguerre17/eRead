import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../controllers/vocabulary_controller.dart';
import '../models/vocabulary.dart';
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'favorite_vocabulary_page.dart';

class VocabularyListScreen extends StatefulWidget {
  final String bookId;
  const VocabularyListScreen({super.key, required this.bookId});

  @override
  State<VocabularyListScreen> createState() => _VocabularyListScreenState();
}

class _VocabularyListScreenState extends State<VocabularyListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<VocabularyController>().fetchVocabulary(widget.bookId);
    });
  }

  Future<void> _refreshVocabulary() async {
    await context.read<VocabularyController>().fetchVocabulary(widget.bookId);
  }

  Future<void> _showStyledDialog({
    required String title,
    required Widget content,
    required VoidCallback onConfirm,
  }) async {
    return showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        backgroundColor: Colors.white,
        elevation: 10,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade100,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(12),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.deepPurple,
                  size: 30,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              content,
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.deepPurple,
                    ),
                    child: const Text("Annuler"),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 3,
                    ),
                    onPressed: onConfirm,
                    child: const Text(
                      "Ajouter",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }


  /// Dialogue pour ajouter ou modifier un mot (version professionnelle)
  /// Dialogue pour ajouter ou modifier un mot (même style que Chapitre / Extrait)
  void _showVocabularyDialog({Vocabulary? vocab}) {
    final wordController =
    TextEditingController(text: vocab?.word ?? '');
    final definitionController =
    TextEditingController(text: vocab?.definition ?? '');
    final exampleController =
    TextEditingController(text: vocab?.example ?? '');

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                /// ====== HEADER ======
                Row(
                  children: [
                    const Icon(Icons.lightbulb, color: Colors.deepPurple),
                    const SizedBox(width: 8),
                    Text(
                      vocab == null
                          ? "Ajouter un mot appris"
                          : "Modifier le mot",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                /// ====== MOT ======
                TextField(
                  controller: wordController,
                  decoration: InputDecoration(
                    labelText: "Mot",
                    prefixIcon: const Icon(Icons.lightbulb_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                /// ====== DÉFINITION ======
                TextField(
                  controller: definitionController,
                  decoration: InputDecoration(
                    labelText: "Définition",
                    prefixIcon: const Icon(Icons.menu_book),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  maxLines: 2,
                ),

                const SizedBox(height: 12),

                /// ====== EXEMPLE ======
                TextField(
                  controller: exampleController,
                  decoration: InputDecoration(
                    labelText: "Exemple (optionnel)",
                    prefixIcon: const Icon(Icons.edit),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  maxLines: 2,
                ),

                const SizedBox(height: 20),

                /// ====== ACTIONS ======
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey.shade700,
                      ),
                      child: const Text("Annuler"),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () async {
                        final word = wordController.text.trim();
                        final definition =
                        definitionController.text.trim();

                        if (word.isEmpty || definition.isEmpty) return;

                        final user =
                            Supabase.instance.client.auth.currentUser;
                        if (user == null) return;

                        final controller =
                        context.read<VocabularyController>();

                        if (vocab == null) {
                          final newVocab = Vocabulary(
                            id: const Uuid().v4(),
                            word: word,
                            definition: definition,
                            example: exampleController.text.trim(),
                            createdAt: DateTime.now(),
                            bookId: widget.bookId,
                            userId: user.id,
                            isSynced: true,
                            isFavorite: false,
                          );
                          await controller.addVocabulary(newVocab);
                        } else {
                          final updatedVocab = Vocabulary(
                            id: vocab.id,
                            word: word,
                            definition: definition,
                            example: exampleController.text.trim(),
                            createdAt: vocab.createdAt,
                            bookId: vocab.bookId,
                            userId: vocab.userId,
                            isSynced: true,
                            isFavorite: vocab.isFavorite,
                          );
                          await controller.updateVocabulary(updatedVocab);
                        }

                        if (mounted) Navigator.pop(context);
                      },
                      child: Text(
                        vocab == null ? "Ajouter" : "Modifier",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }




  @override
  Widget build(BuildContext context) {
    final controller = context.watch<VocabularyController>();
    final vocabList = controller.vocabularies;

    final filteredList = vocabList.where((vocab) {
      final word = vocab.word.toLowerCase();
      final q = _searchQuery.toLowerCase();
      return word.contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        title: const Text("Mots appris"),
        actions: [
          IconButton(
            icon: const Icon(Icons.star, color: Colors.amber),
            tooltip: "Mots favoris",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FavoriteVocabularyScreen(),
                ),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Rechercher un mot appris...",
                hintStyle: const TextStyle(color: Colors.white70),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
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
      ),

      body: controller.isLoading
          ? _vocabularyShimmer()
          : RefreshIndicator(
        onRefresh: _refreshVocabulary,
        child: filteredList.isEmpty
            ? const Center(
            child: Text("Aucun mot trouvé.", style: TextStyle(fontSize: 16)))
            : ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: filteredList.length,
          itemBuilder: (context, index) {
            final vocab = filteredList[index];

            return Dismissible(
              key: Key(vocab.id),
              background: Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.edit, color: Colors.white),
              ),
              secondaryBackground: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              direction: DismissDirection.horizontal,
              confirmDismiss: (direction) async {
                if (direction == DismissDirection.startToEnd) {
                  _showVocabularyDialog(vocab: vocab);
                  return false;
                } else if (direction == DismissDirection.endToStart) {
                  return await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text("Supprimer"),
                      content: Text("Supprimer le mot \"${vocab.word}\" ?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: const Text("Annuler"),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent),
                          onPressed: () => Navigator.of(ctx).pop(true),
                          child: const Text("Supprimer"),
                        ),
                      ],
                    ),
                  );
                }
                return false;
              },
              onDismissed: (direction) async {
                if (direction == DismissDirection.endToStart) {
                  final removed = vocab;
                  try {
                    await controller.deleteVocabulary(vocab.id);
                    if (!mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Mot supprimé: ${vocab.word}'),
                        action: SnackBarAction(
                          label: 'Annuler',
                          onPressed: () async {
                            await controller.addVocabulary(removed);
                            await controller.fetchVocabulary(widget.bookId);
                          },
                        ),
                      ),
                    );
                  } catch (e) {
                    debugPrint('Erreur suppression vocab: $e');
                    await controller.fetchVocabulary(widget.bookId);
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Erreur lors de la suppression.")),
                    );
                  }
                }
              },
              child: Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.lightbulb_outline, color: Colors.deepPurple),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              vocab.word,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                          // ⭐ Bouton Favoris
                          IconButton(
                            icon: Icon(
                              vocab.isFavorite ? Icons.star : Icons.star_border,
                              color: Colors.amber,
                            ),
                            onPressed: () async {
                              await controller.toggleFavorite(vocab);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text("Définition : ${vocab.definition}",
                          style: const TextStyle(fontSize: 16)),
                      if (vocab.example != null && vocab.example!.trim().isNotEmpty)
                        ...[
                          const SizedBox(height: 6),
                          Text(
                            "Exemple : ${vocab.example}",
                            style: const TextStyle(
                                fontSize: 15,
                                fontStyle: FontStyle.italic,
                                color: Colors.grey),
                          ),
                        ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'addVocabulary',
        backgroundColor: Colors.deepPurple.shade700,
        shape: const StadiumBorder(), // ✅ PILULE
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Mot",
          style: TextStyle(color: Colors.white),
        ),
        onPressed: _showVocabularyDialog,
      ),

    );
  }
}

Widget _vocabularyShimmer() {
  return ListView.builder(
    padding: const EdgeInsets.all(12),
    itemCount: 6,
    itemBuilder: (_, __) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );
    },
  );
}


