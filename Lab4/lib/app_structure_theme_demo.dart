// Exercise 4 – App Structure with Scaffold, AppBar, FAB & Theme
// File: lib/app_structure_theme_demo.dart

import 'package:flutter/material.dart';

void main() {
  runApp(const StandaloneAppStructureThemeDemo());
}

class StandaloneAppStructureThemeDemo extends StatefulWidget {
  const StandaloneAppStructureThemeDemo({super.key});

  @override
  State<StandaloneAppStructureThemeDemo> createState() =>
      _StandaloneAppStructureThemeDemoState();
}

class _StandaloneAppStructureThemeDemoState
    extends State<StandaloneAppStructureThemeDemo> {
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF9F9FB),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      home: AppStructureThemeDemo(
        isDarkMode: _isDarkMode,
        onToggleTheme: (val) {
          setState(() {
            _isDarkMode = val;
          });
        },
      ),
    );
  }
}

class AppStructureThemeDemo extends StatelessWidget {
  final bool isDarkMode;
  final Function(bool) onToggleTheme;

  const AppStructureThemeDemo({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise 4 – App Str...'),
        actions: [
          Row(
            children: [
              const Text('Dark', style: TextStyle(fontSize: 14)),
              Switch(
                value: isDarkMode,
                onChanged: onToggleTheme,
              ),
              const SizedBox(width: 8),
            ],
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'This is a simple screen with theme toggle.',
          style: TextStyle(fontSize: 14, color: Colors.black54),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('FloatingActionButton Clicked!')),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

