import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:shimmer/shimmer.dart';
import '../controllers/ChapterController.dart';
import '../controllers/ExcerptController.dart';
import '../controllers/vocabulary_controller.dart';
import '../models/book.dart';
import '../models/excerpt.dart';
import 'expression_list_page.dart';
import 'vocabulary_list_screen.dart';

class BookDetailScreen extends StatefulWidget {
  final Book book;
  const BookDetailScreen({super.key, required this.book});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  final uuid = const Uuid();
  bool _showLearningActions = false;

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

  // ==================== DIALOGUE GÉNÉRIQUE ====================

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

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: const [
                    Icon(Icons.menu_book, color: Colors.deepPurple),
                    SizedBox(width: 8),
                    Text(
                      "Ajouter un chapitre",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: "Titre du chapitre",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.title),
                  ),
                ),

                const SizedBox(height: 20),

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
                        final title = titleController.text.trim();
                        if (title.isEmpty) return;

                        final user =
                            Supabase.instance.client.auth.currentUser;
                        if (user == null) return;

                        await context
                            .read<ChapterController>()
                            .addChapter(title, widget.book.id, user.id);

                        if (mounted) Navigator.pop(context);
                      },
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
      ),
    );
  }


  void _addExcerptDialog(String chapterId) {
    final contentController = TextEditingController();
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: const [
                    Icon(Icons.format_quote, color: Colors.deepPurple),
                    SizedBox(width: 8),
                    Text(
                      "Ajouter un extrait",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                TextField(
                  controller: contentController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: "Texte de l'extrait",
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.text_snippet),
                  ),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: commentController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: "Commentaire (optionnel)",
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.comment),
                  ),
                ),

                const SizedBox(height: 20),

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
                        final content = contentController.text.trim();
                        if (content.isEmpty) return;

                        final user =
                            Supabase.instance.client.auth.currentUser;
                        if (user == null) return;

                        await context.read<ExcerptController>().addExcerpt(
                          chapterId,
                          content,
                          commentController.text.trim(),
                        );

                        await context
                            .read<ExcerptController>()
                            .fetchExcerpts(chapterId);

                        if (mounted) Navigator.pop(context);
                      },
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
      ),
    );
  }


  void _editChapterDialog(String chapterId, String currentTitle) {
    final controller = TextEditingController(text: currentTitle);

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Modifier le chapitre",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: "Titre du chapitre",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Annuler"),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                    ),
                    onPressed: () async {
                      final newTitle = controller.text.trim();
                      if (newTitle.isEmpty) return;

                      await context
                          .read<ChapterController>()
                          .updateChapterTitle(chapterId, newTitle);

                      await context
                          .read<ChapterController>()
                          .fetchChapters(widget.book.id);

                      if (mounted) Navigator.pop(context);
                    },
                    child: const Text(
                      "Enregistrer",
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




  /*void _addChapterDialog() {
    final controller = TextEditingController();

    _showStyledDialog(
      title: "Ajouter un chapitre",
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(labelText: "Titre"),
      ),
      onConfirm: () async {
        if (controller.text.trim().isEmpty) return;
        final user = Supabase.instance.client.auth.currentUser;
        if (user == null) return;

        await context
            .read<ChapterController>()
            .addChapter(controller.text.trim(), widget.book.id, user.id);

        if (mounted) Navigator.pop(context);
      },
    );
  }*/

  /*void _addExcerptDialog(String chapterId) {
    final contentController = TextEditingController();
    final commentController = TextEditingController();

    _showStyledDialog(
      title: "Ajouter un extrait",
      content: Column(
        children: [
          TextField(
            controller: contentController,
            maxLines: 3,
            decoration: const InputDecoration(labelText: "Extrait"),
          ),
          TextField(
            controller: commentController,
            maxLines: 2,
            decoration: const InputDecoration(labelText: "Commentaire"),
          ),
        ],
      ),
      onConfirm: () async {
        if (contentController.text.trim().isEmpty) return;

        await context.read<ExcerptController>().addExcerpt(
          chapterId,
          contentController.text.trim(),
          commentController.text.trim(),
        );

        await context.read<ExcerptController>().fetchExcerpts(chapterId);
        if (mounted) Navigator.pop(context);
      },
    );
  }*/

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
        return Dismissible(
          key: Key(ex.id),
          background: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.green.shade400,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.edit, color: Colors.white),
          ),
          secondaryBackground: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.redAccent.shade400,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.endToStart) {
              // Supprimer
              return await showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Supprimer l'extrait"),
                  content: const Text("Voulez-vous vraiment supprimer cet extrait ?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text("Annuler"),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text("Supprimer", style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
            } else {
              // Éditer
              // _editExcerptDialog(ex);
              return false;
            }
          },
          onDismissed: (direction) async {
            if (direction == DismissDirection.endToStart) {
              await excerptController.deleteExcerpt(ex.id, ex.chapterId);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Extrait supprimé ❌"),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 3,
            child: ListTile(
              tileColor: Colors.deepPurple.shade50,
              title: Text(ex.content, style: const TextStyle(fontSize: 16)),
              subtitle: (ex.comment?.isNotEmpty ?? false)
                  ? Text("💬 ${ex.comment}")
                  : null,
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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.deepPurple,
          elevation: 4,
          centerTitle: true,
          leading: Padding(
            padding: const EdgeInsets.only(left: 10, top: 8),
            // child: Material(
            // color: Colors.white,
            // shape: const CircleBorder(),
            // elevation: 4,
            // shadowColor: Colors.black45,
            child: InkWell(
              borderRadius: BorderRadius.circular(50),
              onTap: () => Navigator.pop(context),
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.arrow_back, color: Colors.black),
              ),
            ),
            //  ),
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
                    letterSpacing: 0.3,
                    color: Colors.white),
              ),
              const SizedBox(height: 4),
              const Text(
                "Chapitres, extraits",
                style: TextStyle(fontSize: 17, color: Colors.white70),
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

      floatingActionButton: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [

            /// ================= FAB GAUCHE =================
            Positioned(
              left: 40,
              bottom: 0,
              child: FloatingActionButton.extended(
                heroTag: 'leftFab',
                backgroundColor: Colors.deepPurple,
                shape: const StadiumBorder(), // style pilule
                icon: const Icon(
                  Icons.add,
                  color: Colors.white,
                ),
                label: const Text(
                  "Chapitre",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onPressed: _addChapterDialog,
              ),

            ),

            /// ================= FAB DROITE (MENU) =================
            Positioned(
              right: 16,
              bottom: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [

                  /// EXPRESSIONS
                  AnimatedScale(
                    scale: _showLearningActions ? 1 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: AnimatedOpacity(
                      opacity: _showLearningActions ? 1 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: FloatingActionButton.extended(
                        heroTag: 'expressionsFab',
                        backgroundColor: Colors.deepPurple.shade400,
                        shape: const StadiumBorder(), // ✅ ARRONDI
                        icon: const Icon(Icons.format_quote, color: Colors.white),
                        label: const Text(
                          "Expressions",
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          setState(() => _showLearningActions = false);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ExpressionListScreen(bookId: widget.book.id),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// MOTS APPRIS
                  AnimatedScale(
                    scale: _showLearningActions ? 1 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: AnimatedOpacity(
                      opacity: _showLearningActions ? 1 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: FloatingActionButton.extended(
                        heroTag: 'vocabFab',
                        backgroundColor: Colors.deepPurple.shade600,
                        shape: const StadiumBorder(), // ✅ ARRONDI
                        icon: const Icon(Icons.lightbulb, color: Colors.white),
                        label: const Text(
                          "Mots appris",
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          setState(() => _showLearningActions = false);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  VocabularyListScreen(bookId: widget.book.id),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  /// BOUTON PRINCIPAL (déjà rond, OK)
                  FloatingActionButton(
                    heroTag: 'mainFab',
                    backgroundColor: Colors.deepPurple,
                    onPressed: () {
                      setState(() {
                        _showLearningActions = !_showLearningActions;
                      });
                    },
                    child: AnimatedRotation(
                      turns: _showLearningActions ? 0.125 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        _showLearningActions ? Icons.close : Icons.add,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
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
            /* Text("Auteur : ${widget.book.author}",
                style: const TextStyle(fontSize: 18)),*/
            const SizedBox(height: 20),
            const Text("Chapitres 📚",
                style:
                TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            if (chapters.isEmpty) const Text("Aucun chapitre ajouté."),
            ...chapters.map((chapter) {
              return Dismissible(
                  key: Key(chapter.id),
                  direction: DismissDirection.horizontal,

                  dismissThresholds: const {
                    DismissDirection.startToEnd: 0.15,
                    DismissDirection.endToStart: 0.4,
                  },

                  background: Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade400,
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

                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.startToEnd) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _editChapterDialog(chapter.id, chapter.title);
                      });
                      return false; // ❌ on ne supprime pas
                    }

                    if (direction == DismissDirection.endToStart) {
                      return await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text("Supprimer le chapitre"),
                          content: const Text(
                            "Ce chapitre contient des extraits.\n"
                                "Ils seront tous supprimés définitivement.\n\n"
                                "Continuer ?",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text("Annuler"),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                              ),
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text("Supprimer", style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      );
                    }

                    return false;
                  },

                  onDismissed: (direction) async {
                    if (direction == DismissDirection.endToStart) {
                      await context
                          .read<ChapterController>()
                          .deleteChapter(chapter.id, widget.book.id);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Chapitre supprimé 🗑️")),
                      );
                    }
                  },

              child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: Theme(
                    data: Theme.of(context)
                        .copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      title: Text(
                        chapter.title,
                        style: const TextStyle(fontSize: 18),
                      ),
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
                ),
              );

            }),
          ],
        ),
      ),
    );
  }
}