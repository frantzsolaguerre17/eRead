import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/vocabulary_controller.dart';
import '../models/vocabulary.dart';
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  /// Dialogue pour ajouter ou modifier un mot
  void _showVocabularyDialog({Vocabulary? vocab}) {
    final wordController = TextEditingController(text: vocab?.word ?? '');
    final definitionController = TextEditingController(text: vocab?.definition ?? '');
    final exampleController = TextEditingController(text: vocab?.example ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(vocab == null ? "Ajouter un mot 🧠" : "Modifier le mot 📝"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: wordController,
                decoration: const InputDecoration(
                    labelText: "Mot", prefixIcon: Icon(Icons.lightbulb)),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: definitionController,
                decoration: const InputDecoration(
                    labelText: "Définition", prefixIcon: Icon(Icons.menu_book)),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: exampleController,
                decoration: const InputDecoration(
                    labelText: "Exemple (optionnel)", prefixIcon: Icon(Icons.edit)),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler", style: TextStyle(color: Colors.deepPurple)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
            onPressed: () async {
              final word = wordController.text.trim();
              final definition = definitionController.text.trim();
              if (word.isEmpty || definition.isEmpty) return;

              final user = Supabase.instance.client.auth.currentUser;
              if (user == null) return;

              try {
                final controller = context.read<VocabularyController>();

                if (vocab == null) {
                  // Ajouter
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
                  // Modifier
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

                if (!mounted) return;
                Navigator.pop(context);
              } catch (e) {
                debugPrint('Erreur add/update vocab: $e');
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Erreur lors de l'opération.")),
                );
              }
            },
            child: Text(vocab == null ? "Ajouter" : "Modifier"),
          ),
        ],
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
          title: const Text("Mots favoris"),
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
                  hintText: "Rechercher un mot appris...",
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
      body: controller.isLoading
          ? const Center(child: CircularProgressIndicator())
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
        icon: const Icon(Icons.add),
        label: const Text("Ajouter mot"),
        onPressed: () => _showVocabularyDialog(),
      ),
    );
  }
}
