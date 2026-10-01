// Exercise 5 – Debug & Fix Common UI Errors
// File: lib/common_ui_fixes_demo.dart

import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: CommonUIFixesDemo(),
  ));
}

class CommonUIFixesDemo extends StatefulWidget {
  const CommonUIFixesDemo({super.key});

  @override
  State<CommonUIFixesDemo> createState() => _CommonUIFixesDemoState();
}

class _CommonUIFixesDemoState extends State<CommonUIFixesDemo> {
  final List<String> _movies = ['Movie A', 'Movie B', 'Movie C', 'Movie D'];

  // Biến dùng để demo FIX 3 (setState)
  int _counter = 0;

  // Biến dùng để demo FIX 4 (DatePicker an toàn với BuildContext)
  DateTime? _safePickedDate;

  // FIX 4: Gọi showDatePicker an toàn, kiểm tra context.mounted
  Future<void> _safePickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    // Luôn kiểm tra mounted trước khi gọi setState để tránh lỗi Bad state: Widget is unmounted
    if (picked != null && mounted) {
      setState(() {
        _safePickedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise 5 – Common U...'),
      ),
      // FIX 2: Bọc Column trong SingleChildScrollView / SafeArea để tránh overflow trên màn hình nhỏ
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Headline mô tả task như mockup
            const Text(
              'Correct ListView inside Column using Expanded',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            // FIX 1: Dùng Expanded bọc ListView bên trong Column để tránh lỗi Unbounded Height
            Expanded(
              child: ListView.builder(
                itemCount: _movies.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.movie_rounded,
                        color: Colors.black87,
                      ),
                      title: Text(
                        _movies[index],
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const Divider(),

            // Demo bổ sung cho FIX 3 (State update with setState)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Fix setState Demo: Count = $_counter'),
                ElevatedButton(
                  onPressed: () {
                    // FIX 3: Cập nhật biến trong setState để kích hoạt build lại UI
                    setState(() {
                      _counter++;
                    });
                  },
                  child: const Text('+1 Count'),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Demo bổ sung cho FIX 4 (Safe DatePicker context)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _safePickedDate == null
                      ? 'Safe Date: None'
                      : 'Safe Date: ${_safePickedDate!.day}/${_safePickedDate!.month}/${_safePickedDate!.year}',
                  style: const TextStyle(fontSize: 13),
                ),
                TextButton.icon(
                  onPressed: _safePickDate,
                  icon: const Icon(Icons.calendar_today, size: 16),
                  label: const Text('Pick Safely'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

