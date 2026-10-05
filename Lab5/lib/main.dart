// ============================================================================
// Lab 5 – Building A Movie Detail App With Navigation
// File: lib/main.dart
// ============================================================================

import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MovieDetailApp());
}

class MovieDetailApp extends StatelessWidget {
  const MovieDetailApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie Detail App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3F51B5)),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
