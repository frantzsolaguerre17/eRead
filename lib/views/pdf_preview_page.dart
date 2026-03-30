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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

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
                Text(
                  "Consultation du livre 📖",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.book.title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.7),
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
              return Center(child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ));
            } else if (snapshot.hasData && snapshot.data != null) {
              return SfPdfViewer.file(
                snapshot.data!,
                controller: _pdfController,
                canShowScrollHead: true,
                canShowScrollStatus: true,
                pageLayoutMode: PdfPageLayoutMode.continuous,
              );
            }
            return Center(child: Text(
              "Impossible de charger le PDF",
              style: Theme.of(context).textTheme.bodyMedium,
            ));
          },
        ),
      ),
    );
  }
}
