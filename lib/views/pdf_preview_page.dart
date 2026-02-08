import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/book.dart';
import 'book_details_page.dart';

class PdfPreviewPage extends StatefulWidget {
  final Book book;

  const PdfPreviewPage({required this.book, super.key});

  @override
  State<PdfPreviewPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfPreviewPage> {
  late Future<File?> _pdfFuture;
  final PdfViewerController _pdfController = PdfViewerController();
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _loadSavedPages();
    _pdfFuture = _downloadAndCachePdf();
  }

  Future<void> _loadSavedPages() async {
    final prefs = await SharedPreferences.getInstance();
  }

  Future<File?> _downloadAndCachePdf() async {
    try {
      final dir = await getApplicationDocumentsDirectory();

      final safeTitle =
      widget.book.title.replaceAll(RegExp(r'[^\w\s-]'), '').replaceAll(' ', '_');

      final filePath = '${dir.path}/$safeTitle.pdf';
      final file = File(filePath);

      // ✅ Si le fichier existe déjà, on ne recharge PAS
      if (await file.exists()) {
        return file;
      }

      final response = await http.get(Uri.parse(widget.book.pdf));
      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes, flush: true);
        return file;
      }
    } catch (e) {
      debugPrint("Erreur PDF cache: $e");
    }

    return null;
  }

  @override
  void dispose() {
    _pdfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      /// ✅ APPBAR LÉGÈREMENT PLUS GRAND
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          backgroundColor: Colors.deepPurple,
          elevation: 4,
          centerTitle: true,
          title: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Consultation du livre 📖",
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center, // Centre le texte
                ),
                Text(
                  widget.book.title,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.white70,
                  ),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center, // Centre le texte
                ),
              ],
            ),
          ),
        ),
      ),

      body: SafeArea(
        child: FutureBuilder<File?>(
          future: _pdfFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasData && snapshot.data != null) {
              return SfPdfViewer.file(
                snapshot.data!,
                controller: _pdfController,
                onDocumentLoaded: (details) {
                },
                onPageChanged: (details) {
                },
              );
            }
            return const Center(child: Text("Impossible de charger le PDF"));
          },
        ),
      ),
    );
  }
}
