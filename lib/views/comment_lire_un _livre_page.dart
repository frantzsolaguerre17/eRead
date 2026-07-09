import 'package:flutter/material.dart';
import 'package:memo_livre/views/profil_page.dart';

class ResumeLecturePage extends StatelessWidget {
  const ResumeLecturePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Comment bien lire un livre", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,

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
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            ///HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.deepPurple.shade700,
                    Colors.deepPurple.shade400,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "📘 Comment bien lire un livre",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Apprenez à lire efficacement, comprendre profondément et appliquer ce que vous apprenez.",
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            _card(context, "📖 Lire n’est pas un acte passif",
                "Lire n’est pas simplement parcourir des mots, mais un véritable travail intellectuel. "
                    "Beaucoup de lecteurs restent passifs, ils suivent le texte sans réfléchir. "
                    "Au contraire, ce livre explique que lire doit être un acte actif : il faut interagir avec les idées, "
                    "chercher à comprendre et construire du sens. "
                    "Un lecteur efficace lit avec concentration, curiosité et intention."),

            _card(context, "🧠 Devenir un lecteur actif",
                "Un bon lecteur pose constamment des questions pendant sa lecture : "
                    "Quel est le sujet du livre ? Quel problème l’auteur cherche-t-il à résoudre ? "
                    "Quelles sont les idées principales ? "
                    "Lire devient alors une conversation avec l’auteur, où le lecteur analyse, questionne et réfléchit."),

            _card(context, "📊 Les niveaux de lecture",
                "Le livre décrit quatre niveaux de lecture. "
                    "La lecture élémentaire consiste à comprendre les mots. "
                    "La lecture inspectionnelle permet de parcourir rapidement pour saisir l’essentiel. "
                    "La lecture analytique est une lecture lente et approfondie pour comprendre chaque idée. "
                    "Enfin, la lecture comparative consiste à analyser plusieurs livres sur un même sujet pour enrichir sa vision."),

            _card(context, "🧩 Comprendre la structure du livre",
                "Chaque livre possède une organisation logique. "
                    "Pour bien le comprendre, il faut identifier son plan, ses parties principales et la manière dont les idées sont liées. "
                    "Un bon lecteur voit le livre comme une carte : il comprend la structure globale avant d’entrer dans les détails."),

            _card(context, "💡 Identifier les idées essentielles",
                "Un livre contient souvent beaucoup d’informations, mais toutes ne sont pas importantes. "
                    "Le lecteur doit apprendre à distinguer les idées principales des idées secondaires. "
                    "L’objectif est de retenir l’essentiel et de comprendre le message central de l’auteur."),

            _card(context, "📝 Prendre des notes efficacement",
                "Lire sans écrire est inefficace. Le livre recommande de souligner les passages importants, "
                    "d’écrire des commentaires et de reformuler les idées avec ses propres mots. "
                    "Cela permet de mieux comprendre, mémoriser et s’approprier le contenu."),

            _card(context, "⚖️ Comprendre avant de critiquer",
                "Avant de juger un livre, il faut le comprendre complètement. "
                    "Beaucoup de lecteurs critiquent trop vite sans avoir saisi les idées. "
                    "Une bonne critique repose sur une compréhension claire et honnête du contenu."),

            _card(context, "🔍 Analyser les arguments",
                "Un bon lecteur examine les arguments de l’auteur : "
                    "Quelles preuves utilise-t-il ? Ses idées sont-elles logiques ? "
                    "Cette analyse permet de développer l’esprit critique et de ne pas accepter les idées sans réflexion."),

            _card(context, "📚 Lire plusieurs livres",
                "Pour vraiment comprendre un sujet, il est utile de lire plusieurs livres. "
                    "Cela permet de comparer les idées, de voir différents points de vue et de construire sa propre pensée."),

            _card(context, "🚀 Appliquer ce que l’on apprend",
                "Le but final de la lecture est l’action. "
                    "Lire sans appliquer est inutile. "
                    "Les connaissances doivent être utilisées pour améliorer sa vie, prendre de meilleures décisions et évoluer."),

            const SizedBox(height: 20),

            ///CONCLUSION
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.deepPurple.shade900.withOpacity(0.4)
                    : Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                "🎯 Lire est une compétence puissante qui transforme la manière de penser. "
                    "Un bon lecteur ne se contente pas de lire, il comprend, analyse, critique et applique. "
                    "Ce n’est pas le nombre de livres qui compte, mais la profondeur de compréhension "
                    "et l’impact réel sur la vie.",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ///CARD DESIGN
  Widget _card(BuildContext context, String title, String content) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.deepPurple,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}