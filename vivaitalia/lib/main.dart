import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() => runApp(const VivaItaliaApp());

class VivaItaliaApp extends StatelessWidget {
  const VivaItaliaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Viva Italia',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF006400),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
