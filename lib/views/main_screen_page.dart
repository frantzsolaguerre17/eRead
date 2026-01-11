import 'package:flutter/material.dart';
import 'package:memo_livre/views/favorite_vocabulary_page.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../controllers/book_controller.dart';
import '../controllers/expression_controller.dart';
import '../controllers/vocabulary_controller.dart';
import '../views/book_screen.dart';
import '../widgets/banner_widget.dart';
import 'about_page.dart';
import 'favorite_expression_page.dart';
import 'favorites_book_page.dart';
import 'login_page.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  final supabase = Supabase.instance.client;

  late AnimationController _controller;
  late Animation<double> _fadeAnim;

  String displayName = 'Utilisateur';
  final VocabularyController vocabularyController = VocabularyController();

  @override
  void initState() {
    super.initState();
    _loadDisplayName();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
  }

  void _loadDisplayName() {
    final user = supabase.auth.currentUser;
    if (user != null) {
      displayName = user.userMetadata?['full_name'] ?? 'Utilisateur';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  //CONFIRMATION LOGOUT
  Future<void> _confirmLogout() async {
    final bool? shouldLogout = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text("Déconnexion"),
          content: const Text("Voulez-vous vraiment vous déconnecter ?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Annuler",
                style: TextStyle(color: Colors.deepPurple)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Se déconnecter",
                  style: TextStyle(color: Colors.white)
              ),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      await supabase.auth.signOut();

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookController = context.watch<BookController>();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: FadeTransition(
        opacity: _fadeAnim,
        child: CustomScrollView(
          slivers: [
            // ================= APP BAR =================
            SliverAppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Colors.deepPurple.shade700,
              expandedHeight: 190,
              pinned: true,
              elevation: 2,
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.white),
                  onPressed: _confirmLogout,
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                titlePadding: const EdgeInsets.only(bottom: 16),
                title: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Image.asset(
                        "assets/images/default_image.png",
                        height: 30,
                        width: 30,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "eRead",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 19,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      "assets/images/default_image.png",
                      fit: BoxFit.cover,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.5),
                            Colors.transparent,
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ================= CONTENU =================
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Bonjour, $displayName 👋",
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Prêt à lire quelque chose d'inspirant aujourd’hui ?",
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                    const SizedBox(height: 25),

                    Row(
                      children: [
                        FutureBuilder<int>(
                          future: bookController.getReadBooksCount(),
                          builder: (context, snapshot) {
                            final value =
                            snapshot.connectionState == ConnectionState.waiting
                                ? "..."
                                : (snapshot.data ?? 0).toString();
                            return _buildStatCard(
                              "Livres lus",
                              value,
                              Icons.menu_book_rounded,
                              Colors.deepPurple,
                            );
                          },
                        ),
                        FutureBuilder<int>(
                          future: vocabularyController.getLearnedWordsCount(),
                          builder: (context, snapshot) {
                            final value =
                            snapshot.connectionState == ConnectionState.waiting
                                ? "..."
                                : (snapshot.data ?? 0).toString();
                            return _buildStatCard(
                              "Mots appris",
                              value,
                              Icons.text_fields,
                              Colors.amber,
                            );
                          },
                        ),
                        FutureBuilder<int>(
                          future: context
                              .read<ExpressionController>()
                              .getLearnedExpressionsCount(),
                          builder: (context, snapshot) {
                            final value =
                            snapshot.connectionState == ConnectionState.waiting
                                ? "..."
                                : (snapshot.data ?? 0).toString();
                            return _buildStatCard(
                              "Expr apprises",
                              value,
                              Icons.format_quote,
                              Colors.deepPurple,
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),
                    const Text(
                      "Accès rapide",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _quickAction(
                          Icons.book_outlined,
                          "Livres",
                              () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const BookListPage(),
                            ),
                          ),
                        ),
                        _quickAction(
                          Icons.favorite_border,
                          "Livres Favoris ",
                              () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const FavoriteBooksPage(),
                            ),
                          ),
                        ),
                        _quickAction(
                          Icons.star_border,
                          "Mots Favoris",
                              () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                              const FavoriteVocabularyScreen(),
                            ),
                          ),
                        ),
                        _quickAction(
                          Icons.format_quote,
                          "Expr Favoris",
                              () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                              const FavoriteExpressionScreen(),
                            ),
                          ),
                        ),
                       /* _quickAction(
                          Icons.info_outline,
                          "À propos",
                              () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AboutPage(),
                            ),
                          ),
                        ),*/
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ================= PUB EN BAS =================
           /* const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Center(
                  child: BannerAdWidget(),
                ),
              ),
            ),*/
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 30, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(label),
          ],
        ),
      ),
    );
  }

  Widget _quickAction(
      IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: Colors.deepPurple.withOpacity(0.1),
            child: Icon(icon, color: Colors.deepPurple),
          ),
          const SizedBox(height: 6),
          Text(label),
        ],
      ),
    );
  }
}
