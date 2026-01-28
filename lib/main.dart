import 'package:flutter/material.dart';
import 'package:memo_livre/views/login_page.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'controllers/ChapterController.dart';
import 'controllers/ExcerptController.dart';
import 'controllers/book_controller.dart';
import 'controllers/expression_controller.dart';
import 'controllers/notifications_controller.dart';
import 'controllers/vocabulary_controller.dart';

Future<void> main() async{

  /*Avant de démarrer ton application (runApp()), cette ligne
  prépare Flutter à exécuter du code asynchrone au tout début*/
  WidgetsFlutterBinding.ensureInitialized();
  //await MobileAds.instance.initialize();
  //Clés Supabase
  await Supabase.initialize(
    url: 'https://ujuswyzvftkkjklktwxv.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVqdXN3eXp2ZnRra2prbGt0d3h2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc3OTg5NTcsImV4cCI6MjA3MzM3NDk1N30.7QGTmDz_yaGo4B4XXHBA71PivmTElC5Zx4sjpuv_w8Y',
  );
 // await Firebase.initializeApp();
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
        ChangeNotifierProvider(create: (_) => ExpressionController()),
        ChangeNotifierProvider(create: (_) => NotificationController()),
      ],
      child: MaterialApp(
        title: 'eRead Auth',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        ),

        debugShowCheckedModeBanner: false,
        home: const LoginPage(),
      ),
    );
  }

}
