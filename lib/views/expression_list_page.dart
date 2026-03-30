import 'package:flutter/material.dart';
import 'package:memo_livre/views/favorite_expression_page.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../controllers/expression_controller.dart';
import '../models/expression.dart';

class ExpressionListScreen extends StatefulWidget {
  final String bookId;

  const ExpressionListScreen({super.key, required this.bookId});

  @override
  State<ExpressionListScreen> createState() => _ExpressionListScreenState();
}

class _ExpressionListScreenState extends State<ExpressionListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context
          .read<ExpressionController>()
          .fetchExpressions(widget.bookId);
    });
  }

  Future<void> _refreshExpressions() async {
    await context
        .read<ExpressionController>()
        .fetchExpressions(widget.bookId);
  }

  /// =========================
  /// DIALOG AJOUT / MODIFICATION
  /// =========================
  void _showExpressionDialog({Expression? expression}) {
    final textController =
    TextEditingController(text: expression?.expressionText ?? '');
    final definitionController =
    TextEditingController(text: expression?.definition ?? '');
    final exampleController =
    TextEditingController(text: expression?.example ?? '');

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        insetPadding:
        const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                /// HEADER
                Row(
                  children: [
                    const Icon(Icons.format_quote,
                        color: Colors.deepPurple),
                    const SizedBox(width: 8),
                    Text(
                      expression == null
                          ? "Ajouter une expression"
                          : "Modifier l’expression",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                /// EXPRESSION
                TextField(
                  controller: textController,
                  decoration: InputDecoration(
                    labelText: "Expression",
                    prefixIcon: const Icon(Icons.format_quote),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                /// DÉFINITION
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

                /// EXEMPLE
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

                /// ACTIONS
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
                        final text = textController.text.trim();
                        final definition =
                        definitionController.text.trim();

                        if (text.isEmpty || definition.isEmpty) return;

                        final user =
                            Supabase.instance.client.auth.currentUser;
                        if (user == null) return;

                        final controller =
                        context.read<ExpressionController>();

                        if (expression == null) {
                          final newExpression = Expression(
                            id: const Uuid().v4(),
                            expressionText: text,
                            definition: definition,
                            example: exampleController.text.trim(),
                            createdAt: DateTime.now(),
                            bookId: widget.bookId,
                            userId: user.id,
                            isFavorite: false,
                          );
                          await controller.addExpression(newExpression);
                        } else {
                          expression.expressionText = text;
                          expression.definition = definition;
                          expression.example =
                              exampleController.text.trim();

                          await controller.updateExpression(expression);
                        }

                        if (mounted) Navigator.pop(context);
                      },
                      child: Text(
                        expression == null ? "Ajouter" : "Modifier",
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

  /// =========================
  /// BUILD
  /// =========================
  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ExpressionController>();
    final expressions = controller.expressions;

    final filteredList = expressions.where((exp) {
      return exp.expressionText
          .toLowerCase()
          .contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        title: Text("Expressions apprises",
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
      color: Theme.of(context).colorScheme.onPrimary,
    )
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.star, color: Colors.amber),
            tooltip: "Mots favoris",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FavoriteExpressionScreen(),
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
              onChanged: (value) =>
                  setState(() => _searchQuery = value),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              decoration: InputDecoration(
                hintText: "Rechercher une expression...",
                hintStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.7),
                ),
                prefixIcon:
                 Icon(
                  Icons.search,
                  color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.7),
                ),
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
                fillColor: Theme.of(context).colorScheme.primary.withOpacity(0.8),
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
          ? _expressionShimmer(context)
          : RefreshIndicator(
        onRefresh: _refreshExpressions,
        child: filteredList.isEmpty
            ? Center(
          child: Text(
            "Aucune expression trouvée.",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.color
                  ?.withOpacity(0.6),
            ),
          ),
        )
            : ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: filteredList.length,
          itemBuilder: (context, index) {
            final exp = filteredList[index];

            return Dismissible(
              key: ValueKey(exp.id),
              direction: DismissDirection.horizontal,
              background: Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
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
                  // 👉 Swipe DROITE → MODIFIER
                  _showExpressionDialog(expression: exp);
                  return false; // ❌ on ne dismiss PAS
                }

                if (direction == DismissDirection.endToStart) {
                  // 👈 Swipe GAUCHE → SUPPRIMER
                  return await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Supprimer l'expression"),
                      content: const Text(
                          "Voulez-vous vraiment supprimer cette expression ?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text("Annuler"),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                          child: const Text("Supprimer"),
                        ),
                      ],
                    ),
                  );
                }

                return false;
              },
              onDismissed: (_) async {
                await controller.deleteExpression(exp.id);
              },
              child: Card(
                color: Theme.of(context).cardColor,
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
                          Icon(
                            Icons.format_quote,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              exp.expressionText,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              exp.isFavorite ? Icons.star : Icons.star_border,
                              color: Colors.amber,
                            ),
                            onPressed: () {
                              context
                                  .read<ExpressionController>()
                                  .toggleFavorite(exp);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Définition : ${exp.definition}",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      if (exp.example.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          "Exemple : ${exp.example}",
                          style: TextStyle(
                            fontSize: 15,
                            fontStyle: FontStyle.italic,
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
              ),
            );

          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.deepPurple.shade700,
        shape: const StadiumBorder(), // ✅ STYLE PILULE
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Expression",
          style: TextStyle(color: Colors.white),
        ),
        onPressed: _showExpressionDialog,
      ),
    );
  }
}

Widget _expressionShimmer(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return ListView.builder(
    padding: const EdgeInsets.all(12),
    itemCount: 6,
    itemBuilder: (_, __) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Shimmer.fromColors(
          baseColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
          highlightColor: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );
    },
  );
}