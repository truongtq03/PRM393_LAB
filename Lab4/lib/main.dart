// ============================================================================
// Lab 4 – Flutter UI Fundamentals
// File: lib/main.dart
// ============================================================================

import 'package:flutter/material.dart';
import 'core_widgets_demo.dart';
import 'input_controls_demo.dart';
import 'layout_demo.dart';
import 'app_structure_theme_demo.dart';
import 'common_ui_fixes_demo.dart';

void main() {
  runApp(const Lab4App());
}

class Lab4App extends StatefulWidget {
  const Lab4App({super.key});

  @override
  State<Lab4App> createState() => _Lab4AppState();
}

class _Lab4AppState extends State<Lab4App> {
  // Quản lý trạng thái Theme cho toàn bộ ứng dụng (phục vụ Exercise 4)
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lab 4 - Flutter UI Fundamentals',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF9F9FB),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0.5,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          foregroundColor: Colors.white,
          elevation: 0.5,
        ),
      ),
      home: Lab4MainMenu(
        isDarkMode: _themeMode == ThemeMode.dark,
        onToggleTheme: _toggleTheme,
      ),
    );
  }
}

// Menu chính theo mockup Image 1
class Lab4MainMenu extends StatelessWidget {
  final bool isDarkMode;
  final Function(bool) onToggleTheme;

  const Lab4MainMenu({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> exercises = [
      {
        'title': 'Exercise 1 – Core Widgets Demo',
        'screen': const CoreWidgetsDemo(),
      },
      {
        'title': 'Exercise 2 – Input Controls Demo',
        'screen': const InputControlsDemo(),
      },
      {
        'title': 'Exercise 3 – Layout Demo',
        'screen': const LayoutDemo(),
      },
      {
        'title': 'Exercise 4 – App Structure & Theme',
        'screen': AppStructureThemeDemo(
          isDarkMode: isDarkMode,
          onToggleTheme: onToggleTheme,
        ),
      },
      {
        'title': 'Exercise 5 – Common UI Fixes',
        'screen': const CommonUIFixesDemo(),
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lab 4 – Flutter Fundamentals...'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        itemCount: exercises.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = exercises[index];
          return Card(
            elevation: 0,
            color: Theme.of(context).brightness == Brightness.light
                ? const Color(0xFFF3F4F9)
                : const Color(0xFF232328),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              title: Text(
                item['title'] as String,
                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => item['screen'] as Widget),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

