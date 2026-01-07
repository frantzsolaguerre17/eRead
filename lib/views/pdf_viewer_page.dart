import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  final PdfViewerController _pdfController = PdfViewerController();
  final supabase = Supabase.instance.client;

  int _lastPage = 1;
  int? _markedPage;
  int _totalPages = 1;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _loadSavedPages();
    _pdfFuture = _downloadAndCachePdf();
  }

  Future<void> _loadSavedPages() async {
    final prefs = await SharedPreferences.getInstance();
    _lastPage = prefs.getInt('lastPage_${widget.book.id}') ?? 1;
    _markedPage = prefs.getInt('markedPage_${widget.book.id}');
  }

  Future<void> _saveLastPage(int pageNumber) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('lastPage_${widget.book.id}', pageNumber);
  }

  Future<void> _saveMarkedPage(int pageNumber) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('markedPage_${widget.book.id}', pageNumber);

    setState(() => _markedPage = pageNumber);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("🔖 Page $pageNumber marquée"),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _removeMarkedPage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('markedPage_${widget.book.id}');
    setState(() => _markedPage = null);
  }

  Future<File?> _downloadAndCachePdf() async {
    try {
      final dir = await getTemporaryDirectory();
      final filePath =
          '${dir.path}/${widget.book.title.replaceAll(' ', '_')}.pdf';
      final file = File(filePath);

      if (file.existsSync()) return file;

      final response = await http.get(Uri.parse(widget.book.pdf));
      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes, flush: true);
        return file;
      }
    } catch (_) {}
    return null;
  }

  Future<void> _updateProgress(int currentPage) async {
    if (_totalPages == 0) return;

    final percent = ((currentPage / _totalPages) * 100).round();
    final user = supabase.auth.currentUser;
    if (user == null) return;

    setState(() => _progress = currentPage / _totalPages);

    final payload = {
      'user_id': user.id,
      'book_id': widget.book.id,
      'reading_progress': percent,
      'is_read': percent >= 80,
    };

    try {
      await supabase
          .from('user_book_progress')
          .upsert(payload, onConflict: 'user_id,book_id');
    } catch (_) {}
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
                  "Lecture du livre 📖",
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
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.bookmark, color: Colors.white),
              onSelected: (value) {
                if (value == 'mark') {
                  _saveMarkedPage(_pdfController.pageNumber);
                } else if (value == 'remove') {
                  _removeMarkedPage();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'mark', child: Text('Marquer la page')),
                if (_markedPage != null)
                  const PopupMenuItem(
                    value: 'remove',
                    child: Text('Supprimer le marque-page'),
                  ),
              ],
            )
          ],
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
                  _totalPages = details.document.pages.count;
                  _pdfController.jumpToPage(_markedPage ?? _lastPage);
                  _updateProgress(_lastPage);
                },
                onPageChanged: (details) {
                  _saveLastPage(details.newPageNumber);
                  _updateProgress(details.newPageNumber);
                },
              );
            }
            return const Center(child: Text("Impossible de charger le PDF"));
          },
        ),
      ),

      /// ✅ FLOATING BUTTONS
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_markedPage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: FloatingActionButton(
                heroTag: "bookmarkFab",
                backgroundColor: Colors.orange,
                onPressed: () {
                  _pdfController.jumpToPage(_markedPage!);
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.bookmark, size: 22),
                    Text(
                      "$_markedPage",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          FloatingActionButton.extended(
            heroTag: "notesFab",
            backgroundColor: Colors.deepPurple,
            icon: const Icon(Icons.note_add),
            label: const Text("Notes"),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BookDetailScreen(book: widget.book),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
