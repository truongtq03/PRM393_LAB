// Exercise 3 – Layout Basics: Column, Row, Padding, ListView
// File: lib/layout_demo.dart

import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: LayoutDemo(),
  ));
}

class LayoutDemo extends StatelessWidget {
  const LayoutDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> movies = [
      {'title': 'Avatar', 'initial': 'A'},
      {'title': 'Inception', 'initial': 'I'},
      {'title': 'Interstellar', 'initial': 'I'},
      {'title': 'Joker', 'initial': 'J'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise 3 – Layout De...'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Headline Section
            const Text(
              'Now Playing',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // ListView.builder bên trong Expanded để tránh lỗi Unbounded Height
            Expanded(
              child: ListView.builder(
                itemCount: movies.length,
                itemBuilder: (context, index) {
                  final movie = movies[index];
                  return Card(
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 12),
                    color: Theme.of(context).brightness == Brightness.light
                        ? const Color(0xFFF3F4F9)
                        : const Color(0xFF232328),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFFE3EDFA),
                          foregroundColor: const Color(0xFF3F51B5),
                          child: Text(
                            movie['initial']!,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(
                          movie['title']!,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        subtitle: const Text(
                          'Sample description',
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

