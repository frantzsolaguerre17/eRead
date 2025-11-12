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

  // ==================== DIALOGUES avec nouveau design ====================

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
                child: const Icon(Icons.auto_awesome, color: Colors.deepPurple, size: 30),
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
                    child: const Text("Ajouter", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addChapterDialog() {
    final titleController = TextEditingController();

    _showStyledDialog(
      title: "Ajouter un chapitre 📖",
      content: TextField(
        controller: titleController,
        decoration: const InputDecoration(
          labelText: "Titre du chapitre",
          prefixIcon: Icon(Icons.menu_book),
        ),
      ),
      onConfirm: () async {
        final title = titleController.text.trim();
        if (title.isEmpty) return;

        final user = Supabase.instance.client.auth.currentUser;
        if (user == null) return;

        await context
            .read<ChapterController>()
            .addChapter(title, widget.book.id, user.id);

        if (mounted) Navigator.pop(context);
      },
    );
  }

  void _addExcerptDialog(String chapterId) {
    final contentController = TextEditingController();
    final commentController = TextEditingController();

    _showStyledDialog(
      title: "Ajouter un extrait ✍️",
      content: Column(
        children: [
          TextField(
            controller: contentController,
            decoration: const InputDecoration(
              labelText: "Texte de l'extrait",
              prefixIcon: Icon(Icons.format_quote),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 10),
          TextField(
            controller: commentController,
            decoration: const InputDecoration(
              labelText: "Commentaire (optionnel)",
              prefixIcon: Icon(Icons.comment),
            ),
            maxLines: 2,
          ),
        ],
      ),
      onConfirm: () async {
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
    );
  }

  void _addVocabularyDialog() {
    final wordController = TextEditingController();
    final definitionController = TextEditingController();
    final exampleController = TextEditingController();

    _showStyledDialog(
      title: "Ajouter un mot appris 🧠",
      content: Column(
        children: [
          TextField(
            controller: wordController,
            decoration: const InputDecoration(
              labelText: "Mot",
              prefixIcon: Icon(Icons.lightbulb_outline),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: definitionController,
            decoration: const InputDecoration(
              labelText: "Définition",
              prefixIcon: Icon(Icons.book),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 10),
          TextField(
            controller: exampleController,
            decoration: const InputDecoration(
              labelText: "Exemple (optionnel)",
              prefixIcon: Icon(Icons.edit_note),
            ),
            maxLines: 2,
          ),
        ],
      ),
      onConfirm: () async {
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
      children: excerpts.map((ex) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 3,
          child: ListTile(
            tileColor: Colors.deepPurple.shade50,
            title: Text(ex.content, style: const TextStyle(fontSize: 16)),
            subtitle: (ex.comment?.isNotEmpty ?? false)
                ? Text("💬 ${ex.comment}")
                : null,
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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(90),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.deepPurple,
          elevation: 4,
          centerTitle: true,
          leading: Padding(
            padding: const EdgeInsets.only(left: 10, top: 8),
            child: Material(
              color: Colors.white,
              shape: const CircleBorder(),
              elevation: 4,
              shadowColor: Colors.black45,
              child: InkWell(
                borderRadius: BorderRadius.circular(50),
                onTap: () => Navigator.pop(context),
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(Icons.arrow_back, color: Colors.deepPurple),
                ),
              ),
            ),
          ),
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
            children: [
              Text(
                widget.book.title,
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: Colors.white),
              ),
              const SizedBox(height: 4),
              const Text(
                "Chapitres, extraits et mots appris",
                style: TextStyle(fontSize: 13, color: Colors.white70),
              ),
            ],
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(20),
            ),
          ),
        ),
      ),

      // reste inchangé
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton.extended(
              heroTag: 'addChapter',
              backgroundColor: Colors.deepPurple.shade400,
              icon: const Icon(Icons.menu_book),
              label: const Text("Chapitre"),
              onPressed: _addChapterDialog,
            ),
            const SizedBox(width: 10),
            FloatingActionButton.extended(
              heroTag: 'listWords',
              backgroundColor: Colors.deepPurple.shade700,
              icon: const Icon(Icons.lightbulb),
              label: const Text("Mots appris"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        VocabularyListScreen(bookId: widget.book.id),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: chapterController.isLoading
            ? _buildChapterShimmer()
            : ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text("Auteur : ${widget.book.author}",
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            const Text("Chapitres 📚",
                style:
                TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            if (chapters.isEmpty) const Text("Aucun chapitre ajouté."),
            ...chapters.map((chapter) {
              return Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: Theme(
                  data: Theme.of(context)
                      .copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    title: Text(chapter.title,
                        style: const TextStyle(fontSize: 18)),
                    trailing: IconButton(
                      icon: const Icon(Icons.add_circle,
                          color: Colors.deepPurple),
                      onPressed: () => _addExcerptDialog(chapter.id),
                    ),
                    onExpansionChanged: (expanded) {
                      if (expanded) {
                        context
                            .read<ExcerptController>()
                            .fetchExcerpts(chapter.id);
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
