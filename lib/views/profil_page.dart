import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
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
  bool isStatsLoading = true;

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

    setState(() {
      isStatsLoading = true;
    });
    final books = await supabase.from('book').select('id').eq('user_id', user.id).eq('status', 'approved');
    //final books = await supabase.from('book').select('id').eq('user_id', user.id);
    final read = await supabase.from('user_book_progress').select('id').eq('user_id', user.id).eq('is_read', true);
    final words = await supabase.from('vocabulary').select('id').eq('user_id', user.id);
    final expressions = await supabase.from('expression').select('id').eq('user_id', user.id);

    setState(() {
      booksAdded = books.length;
      booksRead = read.length;
      wordsLearned = words.length;
      expressionsLearned = expressions.length;
      isStatsLoading = false;
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
    List<String> parts = title.split(" ");

    String line1 = parts.isNotEmpty ? parts[0] : "";
    String line2 = parts.length > 1 ? parts.sublist(1).join(" ") : "";

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        isStatsLoading
            ? const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        )
            : Text(
          value.toString(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 6),

        Text(
          line1.toUpperCase(),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),

        Text(
          line2.toLowerCase(),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  void showTerms() {
    final ScrollController controller = ScrollController();
    ValueNotifier<bool> showIndicator = ValueNotifier(true);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Termes & Conditions"),
        content: SizedBox(
          width: double.maxFinite,
          child: Stack(
            children: [

              /// 📜 TEXTE SCROLLABLE
              NotificationListener<ScrollNotification>(
                onNotification: (scroll) {
                  if (scroll.metrics.pixels >=
                      scroll.metrics.maxScrollExtent - 20) {
                    showIndicator.value = false;
                  } else {
                    showIndicator.value = true;
                  }
                  return false;
                },
                child: SingleChildScrollView(
                  controller: controller,
                  child: const Text(
                    "Conditions Générales d’Utilisation – eRead\n\n"

                        "Dernière mise à jour : Mai 2026\n\n"

                        "Bienvenue sur eRead, une plateforme de lecture numérique interactive permettant de lire des livres PDF, enregistrer des notes personnelles, sauvegarder des extraits importants, apprendre de nouveaux mots et expressions, et partager des livres avec une communauté de lecteurs.\n\n"

                        "En utilisant l’application eRead, vous acceptez les présentes Conditions Générales d’Utilisation. Si vous n’acceptez pas ces conditions, veuillez ne pas utiliser l’application.\n\n"

                        "1. Objet de l’application\n\n"
                        "eRead est une application de lecture numérique qui permet notamment de :\n"
                        "• Lire des livres\n"
                        "• Ajouter et partager des livres PDF\n"
                        "• Sauvegarder des extraits de lecture\n"
                        "• Enregistrer des mots et expressions appris\n"
                        "• Gérer des favoris\n"
                        "• Suivre sa progression de lecture\n\n"

                        "L’objectif de l’application est de favoriser l’apprentissage, la lecture et le partage de connaissances.\n\n"

                        "2. Création de compte\n\n"
                        "L'utilisation de l'application nécessite la création d’un compte utilisateur.\n\n"

                        "En créant un compte, vous acceptez de :\n"
                        "• Fournir des informations exactes\n"
                        "• Protéger vos identifiants de connexion\n"
                        "• Être responsable des activités effectuées depuis votre compte\n\n"

                        "eRead se réserve le droit de suspendre ou supprimer tout compte en cas d’utilisation abusive ou non conforme.\n\n"

                        "3. Ajout et partage de livres\n\n"
                        "Les utilisateurs peuvent ajouter des livres PDF dans l’application afin de les partager avec la communauté.\n\n"

                        "En ajoutant un livre, vous déclarez que :\n"
                        "• Le contenu ne contient aucun élément offensant, illégal ou dangereux\n\n"

                        "eRead se réserve le droit de :\n"
                        "• Refuser un livre\n"
                        "• Supprimer un contenu\n"
                        "• Suspendre un utilisateur en cas d’abus\n\n"

                        "4. Contenus utilisateur\n\n"
                        "Les utilisateurs peuvent enregistrer :\n"
                        "• Des extraits\n"
                        "• Des commentaires\n"
                        "• Des mots appris\n"
                        "• Des expressions\n"
                        "• Des notes personnelles\n\n"

                        "Chaque utilisateur reste responsable du contenu qu’il publie ou sauvegarde dans l’application.\n\n"

                        "Il est interdit de publier :\n"
                        "• Des contenus illégaux\n"
                        "• Des contenus haineux ou offensants\n"
                        "• Des contenus violant les droits d’autrui\n"
                        "• Des contenus malveillants ou frauduleux\n\n"

                        "5. Respect de la communauté\n\n"
                        "Les utilisateurs doivent adopter un comportement respectueux envers les autres membres de la communauté eRead.\n\n"

                        "Toute tentative de :\n"
                        "• Harcèlement\n"
                        "• Spam\n"
                        "• Publication abusive\n"
                        "• Utilisation frauduleuse\n\n"

                        "peut entraîner une suspension ou suppression du compte.\n\n"

                        "6. Disponibilité du service\n\n"
                        "eRead s’efforce d’assurer un accès continu à l’application, mais ne garantit pas une disponibilité permanente.\n\n"

                        "L’application peut être temporairement indisponible pour :\n"
                        "• Maintenance\n"
                        "• Mise à jour\n"
                        "• Problèmes techniques\n"
                        "• Problèmes liés à Internet\n\n"

                        "7. Données et confidentialité\n\n"
                        "Certaines données utilisateur peuvent être stockées afin d’assurer le bon fonctionnement de l’application, notamment :\n"
                        "• Informations de compte\n"
                        "• Progression de lecture\n"
                        "• Favoris\n"
                        "• Notes et extraits\n"
                        "• Livres ajoutés\n\n"

                        "eRead s’engage à protéger les données des utilisateurs et à ne pas vendre leurs informations personnelles à des tiers.\n\n"

                        "8. Propriété intellectuelle\n\n"
                        "Le nom eRead, son design, son logo et ses fonctionnalités sont protégés.\n\n"

                        "Les contenus ajoutés par les utilisateurs restent la propriété de leurs auteurs respectifs.\n\n"


                        "9. Limitation de responsabilité\n\n"
                        "eRead ne peut être tenu responsable :\n"
                        "• Des contenus publiés par les utilisateurs\n"
                        "• Des erreurs ou interruptions de service\n"
                        "• De la perte de données\n"
                        "• D’une mauvaise utilisation de l’application\n\n"

                        "L’utilisation de l’application se fait sous la responsabilité de l’utilisateur.\n\n"

                        "10. Modifications des conditions\n\n"
                        "Ces conditions peuvent être modifiées à tout moment afin d’améliorer l’application ou de respecter de nouvelles obligations.\n\n"

                        "Les utilisateurs seront informés des mises à jour importantes directement dans l’application.\n\n\n"

                        "📧 Email : frantzsolaguerre17@gmail.com\n\n"
                        "🌐 Portfolio : https://frantzsolaguerre17.github.io/fl-portfolio/\n\n"

                        "Merci d’utiliser eRead 📚",
                    style: TextStyle(fontSize: 15, height: 1.5),
                  ),
                ),
              ),

              /// 👇 INDICATEUR SCROLL
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: ValueListenableBuilder<bool>(
                  valueListenable: showIndicator,
                  builder: (context, value, _) {
                    return AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: value ? 1 : 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Theme.of(context)
                                  .dialogBackgroundColor
                                  .withOpacity(0.95),
                            ],
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.keyboard_arrow_down, size: 22, color: Colors.deepPurple,),
                            SizedBox(width: 6),
                            Text(
                              "Faites défiler pour lire la suite",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.deepPurple
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Fermer"),
          )
        ],
      ),
    );
  }

  /*Future<void> shareApk(BuildContext context) async {
    try {
      final dir = await getTemporaryDirectory();
      //final filePath = '${dir.path}/eread.apk';

      // Charger depuis assets
      final byteData = await rootBundle.load('assets/app_apk/eread.apk');

      final file = File(filePath);

      // Copier vers stockage temporaire
      await file.writeAsBytes(
        byteData.buffer.asUint8List(),
      );

      // Partage
      await Share.shareXFiles(
        [XFile(filePath)],
        text: "📚 Installe eRead",
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur: $e")),
      );
    }
  }*/

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeController>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text("Profil", style: TextStyle(color: Colors.white),),
        centerTitle: true,
        elevation: 2,
        shape: const RoundedRectangleBorder(
          //borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
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

            // Support
            buildCard(Icons.chat, "WhatsApp", openWhatsApp),
            buildCard(Icons.email, "Email", sendEmail),

            // Dark mode
            SwitchListTile(
              value: theme.isDarkMode,
              title: const Text("Mode sombre"),
              onChanged: (val) => theme.toggleTheme(val),
            ),
            // Options
            buildCard(Icons.description, "Termes & Conditions", showTerms),
            /*buildCard(Icons.share, "Partager l'APK", () {
              shareApk(context);
            }),*/

    const SizedBox(height: 20),

    // Logout
    ElevatedButton.icon(
    onPressed: _confirmLogout,
    icon: const Icon(Icons.logout, color: Colors.white,),
    label: const Text("Se déconnecter", style: TextStyle(color: Colors.white)),
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
