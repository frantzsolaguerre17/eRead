import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:shimmer/shimmer.dart';

import '../controllers/ChapterController.dart';
import '../controllers/ExcerptController.dart';
import '../controllers/vocabulary_controller.dart';
import '../models/book.dart';
import '../models/vocabulary.dart';
import 'vocabulary_list_screen.dart';

class BookDetailScreen extends StatefulWidget {
  final Book book;
  const BookDetailScreen({super.key, required this.book});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  final uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    final chapterController = context.read<ChapterController>();
    final vocabController = context.read<VocabularyController>();
    final excerptController = context.read<ExcerptController>();

    excerptController.clearExcerpts();
    await chapterController.fetchChapters(widget.book.id);
    await vocabController.fetchVocabulary(widget.book.id);
  }

  // ==================== DIALOGUES ====================

  void _addChapterDialog() {
    final titleController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text("Ajouter un chapitre 📖"),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(labelText: "Titre du chapitre"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          ElevatedButton(
            onPressed: () async {
              final title = titleController.text.trim();
              if (title.isEmpty) return;

              final user = Supabase.instance.client.auth.currentUser;
              if (user == null) return;

              await context.read<ChapterController>().addChapter(title, widget.book.id, user.id);

              if (mounted) Navigator.pop(context);
            },
            child: const Text("Ajouter"),
          ),
        ],
      ),
    );
  }

  void _addExcerptDialog(String chapterId) {
    final contentController = TextEditingController();
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text("Ajouter un extrait ✍️"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: contentController,
                decoration: const InputDecoration(labelText: "Texte de l'extrait"),
                maxLines: 3,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: commentController,
                decoration: const InputDecoration(labelText: "Commentaire (optionnel)"),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          ElevatedButton(
            onPressed: () async {
              final content = contentController.text.trim();
              if (content.isEmpty) return;

              final user = Supabase.instance.client.auth.currentUser;
              if (user == null) return;

              await context.read<ExcerptController>().addExcerpt(
                chapterId,
                content,
                commentController.text.trim(),
              );

              await context.read<ExcerptController>().fetchExcerpts(chapterId);
              if (mounted) Navigator.pop(context);
            },
            child: const Text("Ajouter"),
          ),
        ],
      ),
    );
  }

  void _addVocabularyDialog() {
    final wordController = TextEditingController();
    final definitionController = TextEditingController();
    final exampleController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text("Ajouter un mot appris 🧠"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: wordController, decoration: const InputDecoration(labelText: "Mot")),
              const SizedBox(height: 10),
              TextField(
                  controller: definitionController,
                  decoration: const InputDecoration(labelText: "Définition"),
                  maxLines: 2),
              const SizedBox(height: 10),
              TextField(
                  controller: exampleController,
                  decoration: const InputDecoration(labelText: "Exemple (optionnel)"),
                  maxLines: 2),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          ElevatedButton(
            onPressed: () async {
              final word = wordController.text.trim();
              final def = definitionController.text.trim();
              if (word.isEmpty || def.isEmpty) return;

              final user = Supabase.instance.client.auth.currentUser;
              if (user == null) return;

              final vocab = Vocabulary(
                id: uuid.v4(),
                bookId: widget.book.id,
                word: word,
                definition: def,
                example: exampleController.text.trim(),
                createdAt: DateTime.now(),
                userId: user.id,
                isSynced: true,
              );

              await context.read<VocabularyController>().addVocabulary(vocab);
              if (mounted) Navigator.pop(context);
            },
            child: const Text("Ajouter"),
          ),
        ],
      ),
    );
  }

  // ==================== AFFICHAGE ====================

  Widget _buildExcerpts(String chapterId) {
    final excerptController = context.watch<ExcerptController>();
    final excerpts = excerptController.getExcerpts(chapterId);

    if (excerptController.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (excerpts.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text("Aucun extrait ajouté."),
      );
    }

    return Column(
      children: excerpts.asMap().entries.map((entry) {
        final index = entry.key;
        final ex = entry.value;

        return TweenAnimationBuilder(
          tween: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero),
          duration: Duration(milliseconds: 300 + index * 100),
          curve: Curves.easeOut,
          builder: (context, Offset offset, child) {
            return Opacity(
              opacity: 1.0 - offset.dy,
              child: Transform.translate(
                offset: Offset(0, offset.dy * 20),
                child: child,
              ),
            );
          },
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 3,
            child: ListTile(
              tileColor: Colors.teal.shade50,
              title: Text(ex.content, style: const TextStyle(fontSize: 16)),
              subtitle: (ex.comment?.isNotEmpty ?? false) ? Text("💬 ${ex.comment}") : null,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildChapterShimmer() {
    return Column(
      children: List.generate(3, (index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }),
    );
  }

  // ==================== BUILD ====================

  @override
  Widget build(BuildContext context) {
    final chapterController = context.watch<ChapterController>();
    final chapters = chapterController.getChapters(widget.book.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book.title),
        backgroundColor: Colors.tealAccent[700],
        centerTitle: true,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton.extended(
                heroTag: 'addChapter',
                backgroundColor: Colors.tealAccent,
                icon: const Icon(Icons.menu_book),
                label: const Text("Chapitre"),
                onPressed: _addChapterDialog,
              ),

              const SizedBox(width: 10),
              FloatingActionButton.extended(
                heroTag: 'listWords',
                backgroundColor: Colors.indigo,
                icon: const Icon(Icons.list),
                label: const Text("Mots appris"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => VocabularyListScreen(bookId: widget.book.id),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: chapterController.isLoading
            ? _buildChapterShimmer()
            : ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text("Auteur : ${widget.book.author}", style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            const Text("Chapitres 📚", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            if (chapters.isEmpty)
              const Text("Aucun chapitre ajouté."),
            ...chapters.map((chapter) {
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    title: Text(chapter.title, style: const TextStyle(fontSize: 18)),
                    trailing: IconButton(
                      icon: const Icon(Icons.add_circle, color: Colors.tealAccent),
                      onPressed: () => _addExcerptDialog(chapter.id),
                    ),
                    onExpansionChanged: (expanded) {
                      if (expanded) {
                        context.read<ExcerptController>().fetchExcerpts(chapter.id);
                      }
                    },
                    children: [_buildExcerpts(chapter.id)],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
