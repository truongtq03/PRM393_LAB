// Exercise 1 – Core Widgets: Text, Image, Icon, Card, ListTile
// File: lib/core_widgets_demo.dart

import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: CoreWidgetsDemo(),
  ));
}

class CoreWidgetsDemo extends StatelessWidget {
  const CoreWidgetsDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise 1 – Core Widge...'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. Headline Text
            const Text(
              'Welcome to Flutter UI',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 24),

            // 2. Icon using Material Icons (Khối icon xanh như ảnh mô tả)
            Container(
              width: 80,
              height: 70,
              decoration: BoxDecoration(
                color: const Color(0xFF2196F3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.movie_creation_rounded,
                size: 48,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),

            // 3. Image.network (Ảnh đường cao tốc phong cảnh)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=800&auto=format&fit=crop&q=60',
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 180,
                  color: Colors.grey.shade300,
                  child: const Center(
                    child: Icon(Icons.broken_image, size: 48, color: Colors.grey),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 4. Card containing a ListTile
            Card(
              elevation: 0,
              color: Theme.of(context).brightness == Brightness.light
                  ? const Color(0xFFF3F4F9)
                  : const Color(0xFF232328),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  leading: Icon(Icons.star, color: Colors.grey, size: 28),
                  title: Text(
                    'Movie Item',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  subtitle: Text(
                    'This is a sample ListTile inside a Card.',
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

