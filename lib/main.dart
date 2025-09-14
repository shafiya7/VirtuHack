import 'package:flutter/material.dart';
import 'login_page.dart';
import 'home_page.dart';
import 'pdf_summarizer_page.dart';
import 'flashcards_page.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DocuLearn',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
        useMaterial3: true,
      ),


      initialRoute: '/login',


      routes: {
        '/login': (_) => const LoginPage(),
        '/home': (_) => const HomePage(),
        '/summarize': (_) => const PdfSummarizerPage(),
        '/flashcards': (_) => const FlashcardsPage(),
      },


      onUnknownRoute: (settings) {
        return MaterialPageRoute(builder: (_) => const LoginPage());
      },
    );
  }
}
