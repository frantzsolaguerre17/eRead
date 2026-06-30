import 'package:flutter/material.dart';
import 'package:memo_livre/views/profil_page.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text(
          "À propos & Guide", style: TextStyle(color: Colors.white)),
        centerTitle: true,

        actions: [
          IconButton(
              icon: const Icon(Icons.account_circle, color: Colors.white),
              tooltip: "Account profil",
              onPressed: () async{
                await Navigator.push(context,
                    MaterialPageRoute(
                        builder: (context) => const ProfilePage()
                    )
                );
              }
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Introduction
            Text(
              "Bienvenue sur eRead 📚",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 10),

            Text(
              "eRead (i-rid) est une plateforme de lecture numérique interactive qui permet de lire des livres PDF tout en gardant une trace des éléments importants de votre lecture. Vous pouvez enregistrer des extraits marquants, conserver les nouveaux mots et expressions appris, organiser vos notes personnelles facilement.\n\n"
                  "L’application offre également la possibilité d'ajouter des livres PDF et les partager avec les autres utilisateurs afin de créer une bibliothèque communautaire accessible à tous.\n\n"
                  "Que vous soyez étudiant, passionné de lecture ou curieux d’apprendre chaque jour, eRead transforme votre lecture en une expérience interactive et enrichissante.",
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),

            const SizedBox(height: 25),

            /// 📘 Lire & partager des livres
            _buildSectionTitle(context, "📘 1. Lire et partager des livres"),
            _buildCard(
              context,
              "Accédez à une large sélection de livres numériques disponibles dans la bibliothèque.\n\n"
                  "Vous pouvez également :\n"
                  "• Importer vos propres fichiers PDF\n"
                  "• Partager vos livres avec la communauté\n"
                  "• Découvrir de nouveaux contenus ajoutés par d’autres utilisateurs\n\n"
                  "L’objectif est de créer une bibliothèque collaborative riche et accessible à tous.",
            ),

            const SizedBox(height: 20),

            /// ❤️ Favoris
            _buildSectionTitle(context, "❤️ 2. Gérer vos favoris"),
            _buildCard(
              context,
              "Gardez une trace de ce qui est important pour vous.\n\n"
                  "Vous pouvez ajouter en favoris :\n"
                  "• Des livres\n"
                  "• Des mots appris\n"
                  "• Des expressions apprises\n\n"
                  "Vos favoris sont centralisés pour un accès rapide et une révision efficace.",
            ),

            const SizedBox(height: 20),

            /// 📖 Mots & expressions
            _buildSectionTitle(context, "📖 3. Suivi des mots et expressions appris"),
            _buildCard(
              context,
              "Améliorez votre vocabulaire pendant votre lecture.\n\n"
                  "Vous pouvez :\n"
                  "• Enregistrer de nouveaux mots et expressions\n"
                  "• Ajouter leurs définitions\n"
                  "• Écrire des exemples d’utilisation\n"
                  "• Marquer comme favori\n\n"
                  "Cette fonctionnalité transforme chaque lecture en opportunité d’apprentissage.",
            ),

            const SizedBox(height: 20),

            /// 📚 Lecture interactive
            _buildSectionTitle(context, "📚 4. Lecture interactive"),
            _buildCard(
              context,
              "Profitez d’une expérience de lecture avancée et personnalisée.\n\n"
                  "Pendant la lecture, vous pouvez :\n"
                  "• Marquer votre page actuelle\n"
                  "• Suivre votre progression dans le livre\n"
                  "• Ajouter le chapitre en cours\n"
                  "• Sauvegarder des passages importants\n\n"
                  "Votre progression est automatiquement enregistrée pour reprendre là où vous vous êtes arrêté.",
            ),

            const SizedBox(height: 20),

            /// ✍️ Extraits & avis
            _buildSectionTitle(context, "✍️ 5. Extraits, avis et commentaires"),
            _buildCard(
              context,
              "Exprimez vos idées et retenez l’essentiel.\n\n"
                  "Vous pouvez :\n"
                  "• Sauvegarder des extraits de texte\n"
                  "• Ajouter vos réflexions et commentaires\n\n"
                  "Astuce : utilisez le swipe (glisser) à droite ou à gauche pour modifier ou supprimer rapidement vos contenus.",
            ),

            const SizedBox(height: 20),

            /// 🔐 Compte & synchronisation
            _buildSectionTitle(context, "🔐 6. Compte"),
            _buildCard(
              context,
                "Votre compte vous permet de sauvegarder toutes vos données.\n\n"
                    "• Vos favoris et notes sont sécurisés\n"
                    "• Vos données sont accessibles sur plusieurs appareils\n"
                    "• Votre progression est sauvegardée automatiquement\n"
                    "• Une même adresse e-mail ne peut être utilisée que pour un seul compte eRead\n"
                    "• En cas d'oubli de votre mot de passe, veuillez contacter l'équipe eRead pour obtenir une assistance\n"
            ),

            const SizedBox(height: 20),

            /// 🚀 Conseils
            _buildSectionTitle(context, "🚀 7. Conseils pour bien utiliser eRead"),
            _buildCard(
              context,
              "Pour une meilleure expérience :\n\n"
                  "• Lisez régulièrement pour améliorer votre apprentissage\n"
                  "• Ajoutez des mots et expressions dès que vous apprenez quelque chose de nouveau\n"
                  "• Utilisez les favoris pour réviser facilement\n\n"
                  "eRead est plus puissant lorsque vous l’utilisez activement.",
            ),

            const SizedBox(height: 20),

            /// 🔔 Notifications
            _buildSectionTitle(context, "🔔 8. Notifications"),
            _buildCard(
              context,
              "Restez informé en temps réel grâce aux notifications.\n\n"
                  "Types de notifications :\n"
                  "• Notifications publiques : nouveaux livres ajoutés à la bibliothèque communautaire\n"
                  "• Notifications privées : informations concernant vos livres ajoutés, comme l’approbation ou le refus d’un livre par l'équipe eRead\n\n"
                  "Les notifications vous permettent de suivre les nouveautés et de rester informé des activités liées à vos contributions sur eRead.",
            ),

            const SizedBox(height: 20),

            /// 👤 Profil
            _buildSectionTitle(context, "👤 9. Votre profil"),
            _buildCard(
              context,
                "Votre profil est votre espace personnel dans eRead.\n\n"
                    "Vous pouvez :\n"
                    "• Voir le nombre de livres que vous avez ajoutés dans l'application\n"
                    "• Voir le nombre de livres que vous avez déjà lus\n"
                    "• Voir le nombre de mots appris pendant vos lectures\n"
                    "• Voir le nombre d'expressions apprises\n\n"
                    "Votre profil reflète votre parcours de lecture, vos apprentissages et votre contribution à la communauté eRead."
            ),

            const SizedBox(height: 20),

            /// 🌐 Connexion
            _buildSectionTitle(context, "🌐 10. Connexion Internet"),
            _buildCard(
              context,
              "eRead nécessite une connexion Internet stable pour fonctionner correctement.\n\n"
                  "Pour une meilleure expérience :\n"
                  "• Utilisez une connexion Wi-Fi ou mobile stable\n"
                  "• Évitez les réseaux lents ou instables\n\n"
                  "Certaines fonctionnalités comme :\n"
                  "• Le chargement des livres\n"
                  "• Les notifications\n"
                  "• Les fonctionnalités LIKE, FAVORIS sur les livres \n"
                  "nécessitent une bonne connexion internet.\n\n"
                  "Une bonne connexion garantit une utilisation fluide et sans interruption.",
            ),

            const SizedBox(height: 30),

            /// 🔻 Footer
            /// 🔻 Footer
            Align(
              alignment: Alignment.center,
              child: Column(
                children: [
                  Text(
                    "Développé par Frantzso Laguerre • 2025–2026 • eRead",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.deepPurple.shade300,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 6),

                  SelectableText(
                    "frantzsolaguerre17@gmail.com",
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 12),

                  InkWell(
                    onTap: () async {
                      final Uri url = Uri.parse(
                        'https://frantzsolaguerre17.github.io/fl-portfolio/',
                      );

                      await launchUrl(
                        url,
                        mode: LaunchMode.externalApplication,
                      );
                    },

                    borderRadius: BorderRadius.circular(10),

                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),

                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.language,
                            size: 18,
                            color: Theme.of(context).colorScheme.primary,
                          ),

                          const SizedBox(width: 8),

                          Text(
                            "Voir le portfolio du développeur",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.primary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔧 Widgets réutilisables
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildCard(BuildContext context, String text) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 15,
          color: Theme.of(context).textTheme.bodyMedium?.color,
          height: 1.4,
        ),
      ),
    );
  }
}