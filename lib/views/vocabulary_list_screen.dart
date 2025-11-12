import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:shimmer/shimmer.dart';

import '../controllers/vocabulary_controller.dart';
import '../models/vocabulary.dart';

class VocabularyListScreen extends StatefulWidget {
  final String bookId;

  const VocabularyListScreen({super.key, required this.bookId});

  @override
  State<VocabularyListScreen> createState() => _VocabularyListScreenState();
}

class _VocabularyListScreenState extends State<VocabularyListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final controller = context.read<VocabularyController>();
      await controller.fetchVocabulary(widget.bookId);
    });
  }

  Future<void> _refreshVocabulary() async {
    final controller = context.read<VocabularyController>();
    await controller.fetchVocabulary(widget.bookId);
  }

  // ==================== DIALOGUE AJOUT VOCABULAIRE ====================
  void _addVocabularyDialog() {
    final wordController = TextEditingController();
    final definitionController = TextEditingController();
    final exampleController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Ajouter un mot appris 🧠",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
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
            child: const Text(
              "Annuler",
              style: TextStyle(color: Colors.deepPurple),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
            ),
            onPressed: () async {
              final word = wordController.text.trim();
              final definition = definitionController.text.trim();
              if (word.isEmpty || definition.isEmpty) return;

              final user = Supabase.instance.client.auth.currentUser;
              if (user == null) return;

              final vocab = Vocabulary(
                id: const Uuid().v4(),
                word: word,
                definition: definition,
                example: exampleController.text.trim(),
                createdAt: DateTime.now(),
                bookId: widget.bookId,
                userId: user.id,
                isSynced: true,
              );

              try {
                await context.read<VocabularyController>().addVocabulary(vocab);
                if (mounted) Navigator.pop(context);
              } catch (e) {
                debugPrint('Erreur addVocabulary: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Impossible d'ajouter le mot.")),
                );
              }
            },
            child: const Text("Ajouter",
              style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ==================== SHIMMER LOADING ====================
  Widget _buildShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              height: 100,
              padding: const EdgeInsets.all(16),
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<VocabularyController>();
    final vocabList = controller.vocabularies;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(90),
        child: AppBar(
          backgroundColor: Colors.deepPurple,
          elevation: 4,
          centerTitle: true,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple.shade700, Colors.deepPurple.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                "Mots Appris",
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: Colors.white),
              ),
              SizedBox(height: 4),
              Text(
                "Visualisez et ajoutez les mots appris en lisant ce livre",
                style: TextStyle(fontSize:13,color: Colors.white70),
              ),
             /* Text("Le pouvoir du moment present",
                  style: TextStyle(fontSize: 13, color: Colors.white))*/
            ],
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(20),
            ),
          ),
        ),
      ),
      body: controller.isLoading
          ? _buildShimmer()
          : RefreshIndicator(
        onRefresh: _refreshVocabulary,
        child: vocabList.isEmpty
            ? const Center(
          child: Text(
            "Aucun mot appris pour ce livre.",
            style: TextStyle(fontSize: 16),
          ),
        )
            : ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: vocabList.length,
          itemBuilder: (context, index) {
            final vocab = vocabList[index];
            return Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.lightbulb_outline,
                            color: Colors.deepPurple),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            vocab.word,
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      /*  if (!vocab.isSynced)
                          const Padding(
                            padding: EdgeInsets.only(left: 6),
                            child: Icon(Icons.cloud_off,
                                color: Colors.red, size: 16),
                          ),*/
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text("Définition : ${vocab.definition}",
                        style: const TextStyle(fontSize: 16)),
                    if (vocab.example != null &&
                        vocab.example!.trim().isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        "Exemple : ${vocab.example}",
                        style: const TextStyle(
                            fontSize: 15,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey),
                      ),
                    ],
                   /* const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        "📅 ${vocab.createdAt.toLocal().toString().split(' ')[0]}",
                        style: const TextStyle(
                            fontSize: 12, color: Colors.grey),
                      ),
                    ),*/
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'addVocabulary',
        backgroundColor: Colors.deepPurple.shade700,
        icon: const Icon(Icons.lightbulb),
        label: const Text("Ajouter mot"),
        onPressed: _addVocabularyDialog,
      ),
    );
  }
}
