import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:memo_livre/services/locale_database_service.dart';
import 'package:memo_livre/views/login_page.dart';
import 'package:memo_livre/views/splashscreen.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'controllers/ChapterController.dart';
import 'controllers/ExcerptController.dart';
import 'controllers/book_controller.dart';
import 'controllers/vocabulary_controller.dart';

Future<void> main() async{

  /*Avant de démarrer ton application (runApp()), cette ligne
  prépare Flutter à exécuter du code asynchrone au tout début*/
  WidgetsFlutterBinding.ensureInitialized();

  //Clés Supabase
  await Supabase.initialize(
    url: 'https://ujuswyzvftkkjklktwxv.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVqdXN3eXp2ZnRra2prbGt0d3h2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc3OTg5NTcsImV4cCI6MjA3MzM3NDk1N30.7QGTmDz_yaGo4B4XXHBA71PivmTElC5Zx4sjpuv_w8Y',
  );
  _monitorNetwork();
  await LocalDBService().database; // Initialise la base locale
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      /* Partages de plusieurs contrôleurs dans l'app Flutter pour
       accéder facilement à leurs données et méthodes depuis n’importe quel écran. */
      providers: [
        ChangeNotifierProvider(create: (_) => BookController()),
        ChangeNotifierProvider(create: (_) => VocabularyController()),
        ChangeNotifierProvider(create: (_) => ChapterController()),
        ChangeNotifierProvider(create: (_) => ExcerptController()),
      ],
      child: MaterialApp(
        title: 'eRead Auth',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        ),

        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
      ),
    );
  }

}


void _monitorNetwork() {
  // Écouter les changements de connectivité
  Connectivity().onConnectivityChanged.listen((status) async {
    if (status != ConnectivityResult.none) {
      print('📶 Connexion détectée, synchronisation en cours...');

      try {
        // 🔁 Synchronisation des livres
      //  await BookController().syncLocalBooks();

        // 🔁 Synchronisation des chapitres
        //await ChapterController().syncLocalChapters();

        // 🔁 Synchronisation des extraits
      //  await ExcerptController().syncLocalExcerpts();

        // 🔁 Synchronisation des vocabulaires
        //await VocabularyController().syncVocabulary();

        print('✅ Synchronisation terminée avec succès.');
      } catch (e) {
        print('⚠️ Erreur lors de la synchronisation : $e');
      }
    } else {
      print('📴 Hors ligne — la synchronisation est en attente.');
    }
  });
}
