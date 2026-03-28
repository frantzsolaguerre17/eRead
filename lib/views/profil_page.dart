import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controllers/notifications_controller.dart';
import '../controllers/theme_controller.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final supabase = Supabase.instance.client;

  String email = "";
  String name = "";

  int booksRead = 0;
  int booksAdded = 0;
  int wordsLearned = 0;
  int expressionsLearned = 0;

  @override
  void initState() {
    super.initState();
    loadUser();
    loadStats();
  }

  void loadUser() {
    final user = supabase.auth.currentUser;
    if (user != null) {
      email = user.email ?? "";
      name = user.userMetadata?['full_name'] ?? "Utilisateur";
      setState(() {});
    }
  }

  Future<void> loadStats() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final books = await supabase.from('book').select('id').eq('user_id', user.id);
    final read = await supabase.from('user_book_progress').select('id').eq('user_id', user.id);
    final words = await supabase.from('vocabulary').select('id').eq('user_id', user.id);
    final expressions = await supabase.from('expression').select('id').eq('user_id', user.id);

    setState(() {
      booksAdded = books.length;
      booksRead = read.length;
      wordsLearned = words.length;
      expressionsLearned = expressions.length;
    });
  }

  Future<void> openWhatsApp() async {
    final url = Uri.parse("https://wa.me/50937405233?text=Bonjour, j'ai une suggestion 📚");
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  Future<void> sendEmail() async {
    final Uri emailUri = Uri(scheme: 'mailto', path: 'frantzsolaguerre17@gmail.com', query: 'subject=Support eRead');
    await launchUrl(emailUri);
  }

  Future<void> logout() async {
    await supabase.auth.signOut();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
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
              child: const Text(
                "Annuler",
                style: TextStyle(color: Colors.deepPurple),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                "Se déconnecter",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    // 👇 ICI SE PASSE LA MAGIE
    if (shouldLogout == true) {
      // 1️⃣ RESET notifications
      context.read<NotificationController>().reset();

      // 2️⃣ Supabase logout
      await Supabase.instance.client.auth.signOut();

      // 3️⃣ Redirection vers login
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
            (_) => false,
      );
    }
  }


  Widget buildCard(IconData icon, String title, VoidCallback onTap) {
    final cardColor = Theme.of(context).cardColor;
    return Card(
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.deepPurple.shade100,
          child: Icon(icon, color: Colors.deepPurple),
        ),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget statItem(String title, int value) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        Text(title, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  void showTerms() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Termes & Conditions"),
        content: const SingleChildScrollView(
          child: Text(
            "Bienvenue sur eRead 📚\n\n"
                "1. Utilisation responsable\n"
                "2. Respect des contenus\n"
                "3. Données sécurisées\n"
                "4. Contact via WhatsApp ou Email\n\n"
                "Merci ❤️",
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Fermer"))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeController>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil"),
        centerTitle: true,
        elevation: 2,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 45,
              backgroundColor: Colors.deepPurple,
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : "U",
                style: const TextStyle(fontSize: 30, color: Colors.white),
              ),
            ),
            const SizedBox(height: 10),
            Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text(email, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium!.color)),
            const SizedBox(height: 20),

            // Stats
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  statItem("Livres Lus", booksRead),
                  statItem("Livres Ajoutés", booksAdded),
                  statItem("Mots Appris", wordsLearned),
                  statItem("Expr. Apprises", expressionsLearned),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Options
            buildCard(Icons.description, "Termes & Conditions", showTerms),

            // Dark mode
            SwitchListTile(
              value: theme.isDarkMode,
              title: const Text("Mode sombre"),
              onChanged: (val) => theme.toggleTheme(val),
            ),

            // Support
            buildCard(Icons.chat, "WhatsApp", openWhatsApp),
            buildCard(Icons.email, "Email", sendEmail),

            const SizedBox(height: 20),

            // Logout
            ElevatedButton.icon(
              onPressed: _confirmLogout,
              icon: const Icon(Icons.logout),
              label: const Text("Se déconnecter"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}