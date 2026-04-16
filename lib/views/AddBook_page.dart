import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:memo_livre/views/profil_page.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../controllers/book_controller.dart';
import '../models/book.dart';
import 'book_screen.dart';
import 'main_screen_page.dart';

class AddBookPage extends StatefulWidget {
  const AddBookPage({super.key});

  @override
  State<AddBookPage> createState() => _AddBookPageState();
}

class _AddBookPageState extends State<AddBookPage> {
  final titleController = TextEditingController();
  final authorController = TextEditingController();
  final pagesController = TextEditingController();
  final supabase = Supabase.instance.client;
  bool isLoading = false;
  bool showMessage = false;

  File? selectedImage;
  File? selectedPdf;
  String? imageUrl;
  String? pdfUrl;

  final List<String> categories = [
    'Biographie',
    'Développement Personnel',
    'Économie / Finance',
    'Histoire',
    'Philosophie',
    'Psychologie',
    'Roman',
    'Science / Technologie',
    'Spiritualité / Religion',
    'Autre'
  ];
  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    checkShowMessage();
  }

  /*Future<bool> _checkStoragePermission() async {
    final status = await Permission.storage.request();
    return status.isGranted;
  }
*/
  String getSafeFileName(String originalName) {
    final extension = originalName.contains('.') ? originalName.split('.').last : '';
    final nameWithoutExt = originalName.split('.').first.replaceAll(RegExp(r'[^\w\-]'), '_');
    return '${Uuid().v4()}_${nameWithoutExt}.$extension';
  }

  Future<void> pickImage() async {
    /*final hasPermission = await _checkStoragePermission();
    if (!hasPermission) {
      _showSnack("Permission refusée pour accéder aux fichiers.");
      return;
    }*/

    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      final tempDir = await getTemporaryDirectory();
      final fileName = result.files.single.name;
      final tempFile = File('${tempDir.path}/$fileName');
      await File(result.files.single.path!).copy(tempFile.path);

      setState(() => selectedImage = tempFile);
    }
  }

  Future<void> pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      setState(() => selectedPdf = file);
    }
  }


  Future<String> uploadFile(File file, String bucket) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception("Utilisateur non connecté");

    final fileName = getSafeFileName(file.path.split('/').last);
    await supabase.storage.from(bucket).upload(fileName, file);

    return supabase.storage.from(bucket).getPublicUrl(fileName);
  }

  Future<void> checkShowMessage() async {
    final prefs = await SharedPreferences.getInstance();

    int count = prefs.getInt('add_book_message_count') ?? 0;

    if (count < 3) {
      setState(() {
        showMessage = true;
      });

      await prefs.setInt('add_book_message_count', count + 1);
    }
  }

  // 🔹 Alerte de confirmation avant l'ajout
  Future<void> _showConfirmationDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Confirmer l’ajout 📚"),
        content: const Text("Voulez-vous vraiment ajouter ce livre dans la bibliothèque ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Annuler", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Confirmer"),
          ),
        ],
      ),
    );
    if (confirmed == true) saveBook();
  }

  Future<void> saveBook() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      _showSnack("Vous devez être connecté pour enregistrer un livre");
      return;
    }

    if (titleController.text.isEmpty ||
        authorController.text.isEmpty ||
        pagesController.text.isEmpty ||
        selectedCategory == null) {
      _showSnack("Veuillez remplir tous les champs et choisir une catégorie");
      return;
    }

    setState(() => isLoading = true);

    try {
      // 🔍 Vérification du doublon
      final existingBooks = await supabase
          .from('book')
          .select()
          .eq('title', titleController.text.trim())
          .eq('author', authorController.text.trim());

      if (existingBooks.isNotEmpty) {
        setState(() => isLoading = false);
        _showDuplicateDialog();
        return;
      }

      // 🔹 Image par défaut si aucune sélection
      if (selectedImage != null) {
        imageUrl = await uploadFile(selectedImage!, 'book_covers');
      } else {
        imageUrl = "assets/images/default_image.png";
      }

      if (selectedPdf != null) {
        pdfUrl = await uploadFile(selectedPdf!, 'book_pdfs');
      }

      final username = await _getUsername();
      final role = await _getUserRole();
      final bookStatus = role == 'admin' ? 'approved' : 'pending';

      final newBook = Book(
        id: const Uuid().v4(),
        title: titleController.text.trim(),
        author: authorController.text.trim(),
        number_of_pages: pagesController.text.trim(),
        createdAt: DateTime.now(),
        isSynced: true,
        cover: imageUrl ?? '',
        pdf: pdfUrl ?? '',
        userId: user.id,
        category: selectedCategory ?? 'Non définie',
        user_name: username,
        status: bookStatus,
      );

      //await supabase.from('book').insert(newBook.toJson());
      //await Provider.of<BookController>(context, listen: false).addBook(newBook, title: '', author: '');
      //await Provider.of<BookController>(context, listen: false).fetchBooks();
      await Provider.of<BookController>(
        context,
        listen: false,
      ).addBook(
        newBook,
        title: newBook.title,
        author: newBook.author,
        numberOfPages: newBook.number_of_pages,
        cover: newBook.cover,
        pdf: newBook.pdf,
        category: newBook.category,
      );
      _showSnack(
        bookStatus == 'approved'
            ? "📘 Livre ajouté et publié avec succès"
            : "📨 Livre envoyé a l'équipe eRead pour verification",
      );

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
            (route) => false,
      );

// Puis ouvrir BookScreen
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const BookListPage()),
      );

     // Navigator.pop(context, true);
      /*Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const BookListPage()),
      );*/
    } catch (e) {
      _showSnack("Erreur : ${e.toString()}");
    } finally {
      setState(() => isLoading = false);
    }
  }


  Future<String> _getUsername() async {
    final user = supabase.auth.currentUser;
    if (user == null) return 'Utilisateur';

    final data = await supabase
        .from('profil')
        .select('username')
        .eq('user_id', user.id)
        .maybeSingle();

    return data?['username'] ?? 'Utilisateur';
  }


  Future<String> _getUserRole() async {
    final user = supabase.auth.currentUser;
    if (user == null) return 'user';

    final data = await supabase
        .from('profil')
        .select('role')
        .eq('user_id', user.id)
        .maybeSingle();

    return data?['role'] ?? 'user';
  }


  // 🔹 Boîte de dialogue en cas de doublon
  void _showDuplicateDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Livre déjà existant 📖", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
          "Ce livre existe déjà dans l'application. "
              "Veuillez vérifier le titre ou l'auteur.",
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK", style: TextStyle(color: Colors.deepPurple)),
          ),
        ],
      ),
    );
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  InputDecoration _inputDecoration(BuildContext context, String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: Theme.of(context).textTheme.bodyMedium?.color,
      ),
      prefixIcon: Icon(
        icon,
        color: Theme.of(context).colorScheme.primary,
      ),
      filled: true,
      fillColor: Theme.of(context).cardColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.primary,
          width: 2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = const TextStyle(fontSize: 16);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(85),
        child: AppBar(
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple.shade700, Colors.deepPurple.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          centerTitle: true,
          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                "Ajouter un livre",
                style: TextStyle(fontSize: 22, color: Colors.white),
              ),
              Text(
                "Ajoutez un livre et partagez-le avec la communauté eRead",
                style: TextStyle(fontSize: 12, color: Colors.white),
              )
            ],
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          ),

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
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Card(
            color: Theme.of(context).cardColor,
            elevation: 6,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showMessage)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.info_outline, color: Colors.orange),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "Important",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                              "Veuillez bien remplir toutes les informations du livre :\n\n"
                                  "• Bien écrire le nom du livre\n"
                                  "• Bien écrire le nom de l’auteur\n"
                                  "• Bien indiquer le nombre de pages\n"
                                  "• Bien choisir la catégorie\n"
                                  "• Choisir une image claire, de bonne qualité, correspondant à la couverture officielle du livre (pas une image quelconque)\n\n"
                                  "⚠️ Toute petite erreur peut entraîner le refus du livre.\n\n"
                                  "Si le livre est approuvé, il sera ajouté à la liste des livres de l’application et visible par tous les utilisateurs.\n\n"
                                  "Vous recevrez un message si votre livre est approuvé ou refusé.\n"
                                  "Allez dans 📩 pour vérifier.",
                            style: TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 10),

                          // ✅ Bouton Compris
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                setState(() {
                                  showMessage = false;
                                });
                              },
                              child: const Text("Compris"),
                            ),
                          )
                        ],
                      ),
                    ),

                   Text(
                    "📘 Nouveau livre",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(controller: titleController, decoration: _inputDecoration(context, "Titre du livre", Icons.book), style: textStyle),
                  const SizedBox(height: 16),
                  TextField(controller: authorController, decoration: _inputDecoration(context, "Auteur", Icons.person_outline), style: textStyle),
                  const SizedBox(height: 16),
                  TextField(controller: pagesController, keyboardType: TextInputType.number, decoration: _inputDecoration(context, "Nombre de pages", Icons.numbers), style: textStyle),
                  const SizedBox(height: 16),

                  InputDecorator(
                    decoration: _inputDecoration(context, "Catégorie", Icons.category),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedCategory,
                        isExpanded: true,
                        hint: Text(
                          "Sélectionnez une catégorie",
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                        items: categories.map((cat) {
                          return DropdownMenuItem(
                            value: cat,
                            child: Text(cat),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedCategory = value;
                          });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: pickImage,
                    child: Container(
                      height: 170,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Theme.of(context).dividerColor,
                        ),
                      ),
                      child: selectedImage == null
                          ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.image_outlined, size: 40, color: Theme.of(context).colorScheme.primary),
                            SizedBox(height: 8),
                            Text("Appuyez pour choisir une image"),
                          ],
                        ),
                      )
                          : ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.file(selectedImage!, fit: BoxFit.cover),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  ElevatedButton.icon(
                    onPressed: pickPdf,
                    icon: const Icon(Icons.picture_as_pdf_outlined),
                    label: Text(
                      selectedPdf == null
                          ? "Choisir un fichier PDF"
                          : "PDF : ${selectedPdf!.path.split('/').last}",
                      overflow: TextOverflow.ellipsis,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 4,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: isLoading ? null : _showConfirmationDialog,
                      icon: const Icon(Icons.save_rounded),
                      label: isLoading
                          ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text("Enregistrer"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                        textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 6,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}