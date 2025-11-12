import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../controllers/book_controller.dart';
import '../views/book_screen.dart';

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
      setState(() {
        displayName = user.userMetadata?['full_name'] ?? 'Utilisateur';
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookController = Provider.of<BookController>(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: FadeTransition(
        opacity: _fadeAnim,
        child: CustomScrollView(
          slivers: [
            // 🧢 AppBar en dégradé DeepPurple
            SliverAppBar(
              backgroundColor: Colors.deepPurple.shade700,
              expandedHeight: 170,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text(
                  "eRead",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.deepPurple.shade700, Colors.deepPurple.shade400],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
              elevation: 2,
            ),

            // 🌿 Contenu principal
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 👋 Section Bonjour
                    Text(
                      "Bonjour, $displayName 👋",
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Prêt à lire quelque chose d'inspirant aujourd’hui ?",
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                    const SizedBox(height: 25),

                    // 📊 Statistiques
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatCard(
                          "Livres",
                          "${bookController.books.length}",
                          Icons.menu_book_rounded,
                          Colors.deepPurple,
                        ),
                        _buildStatCard(
                          "Favoris",
                          "0",
                          Icons.favorite,
                          Colors.redAccent,
                        ),
                        _buildStatCard(
                          "Mots appris",
                          "0",
                          Icons.text_fields,
                          Colors.amber,
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // ⚡ Accès rapide
                    Text(
                      "Accès rapide",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 🎯 Icônes de navigation
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildQuickAction(
                          icon: Icons.book_rounded,
                          label: "Mes livres",
                          color: Colors.deepPurple,
                          onTap: () => Navigator.of(context).push(_createRoute()),
                        ),
                        _buildQuickAction(
                          icon: Icons.star_border_rounded,
                          label: "Favoris",
                          color: Colors.deepPurple.shade300,
                          onTap: () {},
                        ),
                        _buildQuickAction(
                          icon: Icons.person_outline,
                          label: "Profil",
                          color: Colors.deepPurple.shade200,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🧩 Carte statistique
  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
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
            Text(
              label,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  /// 🧭 Boutons d’action rapide
  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[800],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// 🪄 Animation de transition vers la liste des livres
  Route _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
      const BookListPage(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        final tween =
        Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.easeOut));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }
}
