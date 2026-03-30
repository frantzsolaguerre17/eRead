import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text(
          "À propos & Guide",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
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
              "eRead (i-rid) est une application de lecture intelligente qui vous permet de lire, apprendre, mémoriser et partager vos connaissances avec la communauté.",
              style: TextStyle(fontSize: 16, color: Theme.of(context).textTheme.bodyMedium?.color),
            ),

            const SizedBox(height: 25),

            /// 📘 Lire & partager des livres
            _buildSectionTitle(context, "📘 1. Lire et partager des livres"),
            _buildCard(context,
              "Accédez à une large sélection de livres numériques. "
                  "Vous pouvez également ajouter vos propres livres PDF et les partager avec la communauté eRead afin d’enrichir la bibliothèque collective.",
            ),

            const SizedBox(height: 20),

            /// ❤️ Favoris
            _buildSectionTitle(context, "❤️ 2. Gérer vos favoris"),
            _buildCard(context,
              "Ajoutez des livres, des mots et des expressions en favoris. "
                  "Retrouvez-les facilement dans les sections dédiées pour un accès rapide.",
            ),

            const SizedBox(height: 20),

            /// 📖 Mots & expressions
            _buildSectionTitle(context, "📖 3. Suivi des mots et expressions appris"),
            _buildCard(context,
              "Pendant votre lecture, vous pouvez enregistrer les mots et expressions que vous apprenez. "
                  "Ajoutez une définition, un exemple et marquez-les comme favoris pour mieux les mémoriser.",
            ),

            const SizedBox(height: 20),

            /// 📚 Lecture intelligente
            _buildSectionTitle(context, "📚 4. Lecture interactive"),
            _buildCard(context,
              "Pendant la lecture d’un livre, vous pouvez marquer une page, "
                  "ajouter le chapitre que vous lisez et sauvegarder les extraits qui vous ont marqué.",
            ),

            const SizedBox(height: 20),

            /// ✍️ Extraits & avis
            _buildSectionTitle(context, "✍️ 5. Extraits, avis et commentaires"),
            _buildCard(context,
              "Ajoutez vos propres avis et commentaires sur un passage précis. "
                  "Vous pouvez modifier ou supprimer un extrait, une expression ou un mot appris "
                  "grâce à un simple swipe vers la droite ou la gauche.",
            ),

            const SizedBox(height: 30),

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
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
                    ),
                    textAlign: TextAlign.center,
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
