import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../models/book.dart';
import 'book_details_page.dart';

class PdfViewerPage extends StatefulWidget {
  final Book book;

  const PdfViewerPage({required this.book, super.key});

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  late Future<File?> _pdfFuture;

  @override
  void initState() {
    super.initState();
    _pdfFuture = _downloadAndCachePdf();
  }

  /// 📥 Télécharge le PDF et le met en cache local
  Future<File?> _downloadAndCachePdf() async {
    try {
      final dir = await getTemporaryDirectory();
      final filePath = '${dir.path}/${widget.book.title}.pdf';
      final file = File(filePath);

      // ✅ Si le PDF existe déjà, on l'utilise
      if (file.existsSync()) return file;

      final response = await http.get(Uri.parse(widget.book.pdf));
      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes, flush: true);
        return file;
      } else {
        throw Exception('Erreur lors du téléchargement du PDF');
      }
    } catch (e) {
      debugPrint('Erreur PDF: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(90),
        child: AppBar(
          backgroundColor: Colors.deepPurple,
          elevation: 4,
          centerTitle: true,
          automaticallyImplyLeading: false,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple.shade700, Colors.deepPurple.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
          ),
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Lecture du livre 📖",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: Colors.white),
              ),
              const SizedBox(height: 4),
              Text(
                widget.book.title,
                style: const TextStyle(fontSize: 14, color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(20),
            ),
          ),
        ),
      ),
      body: FutureBuilder<File?>(
        future: _pdfFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData && snapshot.data != null) {
            return SfPdfViewer.file(
              snapshot.data!,
              enableTextSelection: true,
              pageLayoutMode: PdfPageLayoutMode.single, // plus fluide
            );
          } else {
            return const Center(child: Text("Impossible de charger le PDF"));
          }
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.deepPurple.shade700,
        icon: const Icon(Icons.note_add),
        label: const Text("Prendre des notes"),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BookDetailScreen(book: widget.book),
            ),
          );
        },
      ),
    );
  }
}
