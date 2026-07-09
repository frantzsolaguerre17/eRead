import 'package:flutter/material.dart';
import 'package:memo_livre/views/profil_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReadBooksScreen extends StatefulWidget {
  const ReadBooksScreen({super.key});

  @override
  State<ReadBooksScreen> createState() => _ReadBooksScreenState();
}

class _ReadBooksScreenState extends State<ReadBooksScreen> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> books = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchReadBooks();
  }

  Future<void> fetchReadBooks() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final data = await supabase
        .from('user_book_progress')
        .select('*, book(*)')
        .eq('user_id', user.id)
        .eq('is_read', true);

    setState(() {
      books = List<Map<String, dynamic>>.from(data);
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        title: const Text(
          "Livres déjà lus",
          style: TextStyle(color: Colors.white),
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : books.isEmpty
          ? const Center(
        child: Text(
          "Aucun livre lu.",
          style: TextStyle(fontSize: 16),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: books.length,
        itemBuilder: (context, index) {
          final progress = books[index];
          final book = progress['book'];

          return Card(
            color: Theme.of(context).cardColor,
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: SizedBox(
              height: 160,
              child: Row(
                children: [

                  // IMAGE
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                    ),
                    child: book['cover'] != null && book['cover'].toString().isNotEmpty
                        ? Image.network(
                      book['cover'],
                      width: 120,
                      height: 160,
                      fit: BoxFit.cover,
                    )
                        : Container(
                      width: 120,
                      height: 160,
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      child: const Icon(Icons.book, size: 50),
                    ),
                  ),

                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Stack(
                        children: [

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              Text(
                                book['title'] ?? "",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 6),

                              Row(
                                children: [
                                  const Icon(
                                    Icons.person,
                                    size: 18,
                                    color: Colors.deepPurple,
                                  ),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      book['author'] ?? "",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 6),

                              Row(
                                children: [
                                  const Icon(
                                    Icons.numbers,
                                    size: 18,
                                    color: Colors.orange,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    "${book['number_of_pages']}",
                                  ),
                                ],
                              ),

                              const SizedBox(height: 6),

                              Row(
                                children: [
                                  const Icon(
                                    Icons.category,
                                    size: 18,
                                    color: Colors.deepPurple,
                                  ),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      book['category'] ?? "",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 6),

                            /*  Row(
                                children: [
                                  const Icon(
                                    Icons.person_add,
                                    size: 18,
                                    color: Colors.orange,
                                  ),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      book['user_name'] ?? "",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),*/
                            ],
                          ),

                          // BADGE LU
                          Positioned(
                            right: 0,
                            top: 50,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    "LU",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}