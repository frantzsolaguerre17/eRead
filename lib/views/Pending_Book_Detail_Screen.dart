import 'package:flutter/material.dart';
import 'package:memo_livre/views/pdf_preview_page.dart';
import 'package:memo_livre/views/pdf_viewer_page.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/book.dart';

class PendingBookDetailScreen extends StatelessWidget {
  final Book book;
  final Future<void> Function(Book) onApprove;
  final Future<void> Function(Book) onReject;

  const PendingBookDetailScreen({
    super.key,
    required this.book,
    required this.onApprove,
    required this.onReject,
  });

  Future<void> _openPdf(String url) async {
    final uri = Uri.parse(url);

    if (!await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    )) {
      throw 'Impossible d’ouvrir le PDF';
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Détails du livre"),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            /// IMAGE DU LIVRE
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: book.cover.isNotEmpty
                  ? (book.cover.startsWith('http')
                  ? Image.network(
                book.cover,
                height: 250,
                fit: BoxFit.cover,
              )
                  : Image.asset(
                "assets/images/default_image.png",
                height: 250,
                fit: BoxFit.cover,
              ))
                  : Image.asset(
                "assets/images/default_image.png",
                height: 250,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),

            /// INFOS LIVRE
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withOpacity(0.2),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              book.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            ),
            const SizedBox(height: 8),
            Text("Auteur : ${book.author}"),
            Text("Pages : ${book.number_of_pages}"),
            Text("Catégorie : ${book.category}"),
            Text(
              "Ajouté par : ${book.user_name ?? 'Utilisateur'}",
              style: TextStyle(fontSize: 13, color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6)),
            ),
    ],
        )),
            const SizedBox(height: 16),

            /// BOUTONS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    await onApprove(book);
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                  label: const Text("Approuver", style: TextStyle(color: Colors.white),),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    await onReject(book);
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.cancel_outlined, color: Colors.white),
                  label: const Text("Refuser", style: TextStyle(color: Colors.white),),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            /// BOUTON PDF
            if (book.pdf.isNotEmpty)
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PdfPreviewPage(book: book),
                    ),
                  );
                },
                icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                label: const Text("Ouvrir PDF", style: TextStyle(color: Colors.white),),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
