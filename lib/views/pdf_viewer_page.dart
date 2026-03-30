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
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadSavedPages();
    _loadThemePreference();
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
      final dir = await getApplicationDocumentsDirectory(); // ✅ stockage permanent

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

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('pdf_dark_mode') ?? false;
    });
  }

  Future<void> _toggleDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _isDarkMode = !_isDarkMode);
    await prefs.setBool('pdf_dark_mode', _isDarkMode);
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
                  "Lecture du livre 📖",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                Text(
                  widget.book.title,
                  style: TextStyle(
                    fontSize: 15,
                    color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.7),
                  ),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center, // Centre le texte
                ),
              ],
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                _isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              onPressed: () {
                setState(() {
                  _isDarkMode = !_isDarkMode;
                });
              },
            ),

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
              return Center(child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ));
            } else if (snapshot.hasData && snapshot.data != null) {
              return Column(
                children: [

                  /// 🔥 BARRE DE PROGRESSION
                  LinearProgressIndicator(
                    value: _progress,
                    minHeight: 4,
                    color: Theme.of(context).colorScheme.primary,
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .surfaceVariant,
                  ),

                  /// 📖 PDF
                  Expanded(
                    child: Container(
                      color: _isDarkMode
                          ? Colors.black
                          : Theme.of(context).scaffoldBackgroundColor,
                      child: ColorFiltered(
                        colorFilter: _isDarkMode
                            ? const ColorFilter.matrix([
                          -0.9,0,0,0,255,
                          0,-0.9,0,0,255,
                          0,0,-0.9,0,255,
                          0,0,0,1,0,
                        ])
                            : const ColorFilter.mode(
                          Colors.transparent,
                          BlendMode.dst,
                        ),
                        child: SfPdfViewer.file(
                          snapshot.data!,
                          controller: _pdfController,
                          canShowScrollHead: true,
                          pageSpacing: 2,
                          onDocumentLoaded: (details) {
                            _totalPages = details.document.pages.count;
                            _pdfController.jumpToPage(_markedPage ?? _lastPage);
                            _updateProgress(_lastPage);
                          },
                          onPageChanged: (details) {
                            _saveLastPage(details.newPageNumber);
                            _updateProgress(details.newPageNumber);
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              );

            }
            return Center(child: Text(
              "Impossible de charger le PDF",
              style: Theme.of(context).textTheme.bodyMedium,
            ));
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
                backgroundColor: Theme.of(context).colorScheme.secondary,
                //backgroundColor: Colors.orange,
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
    shape: const StadiumBorder(), //
    icon: const Icon(Icons.note_alt_outlined, color: Colors.white),
    label: const Text(
    "Notes",
    style: TextStyle(color: Colors.white),
    ),
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
