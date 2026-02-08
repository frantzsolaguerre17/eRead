import 'package:flutter/material.dart';
import 'package:memo_livre/views/pdf_preview_page.dart';
import 'package:memo_livre/views/pdf_viewer_page.dart';
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
            Text(
              book.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text("Auteur : ${book.author}"),
            Text("Pages : ${book.number_of_pages}"),
            Text("Catégorie : ${book.category}"),
            Text(
              "Ajouté par : ${book.user_name ?? 'Utilisateur'}",
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
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
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text("Approuver"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    await onReject(book);
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text("Refuser"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
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
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text("Ouvrir PDF"),
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
