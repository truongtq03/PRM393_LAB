// Exercise 2 – Input Widgets: Slider, Switch, RadioListTile, DatePicker
// File: lib/input_controls_demo.dart

import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: InputControlsDemo(),
  ));
}

class InputControlsDemo extends StatefulWidget {
  const InputControlsDemo({super.key});

  @override
  State<InputControlsDemo> createState() => _InputControlsDemoState();
}

class _InputControlsDemoState extends State<InputControlsDemo> {
  double _rating = 50.0;
  bool _isMovieActive = false;
  String? _selectedGenre = 'None';
  DateTime? _selectedDate;

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
    );

    if (picked != null && mounted) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise 2 – Input Contr...'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Rating (Slider)
            const Text(
              'Rating (Slider)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            Slider(
              value: _rating,
              min: 0,
              max: 100,
              divisions: 100,
              activeColor: const Color(0xFF3F51B5),
              onChanged: (val) {
                setState(() => _rating = val);
              },
            ),
            Text(
              'Current value: ${_rating.toInt()}',
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 20),

            // 2. Active (Switch)
            const Text(
              'Active (Switch)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Is movie active?', style: TextStyle(fontSize: 14)),
                Switch(
                  value: _isMovieActive,
                  activeThumbColor: const Color(0xFF3F51B5),
                  onChanged: (val) {
                    setState(() => _isMovieActive = val);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 3. Genre (RadioListTile)
            const Text(
              'Genre (RadioListTile)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            RadioListTile<String>(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: const Text('Action'),
              value: 'Action',
              groupValue: _selectedGenre,
              onChanged: (val) => setState(() => _selectedGenre = val),
            ),
            RadioListTile<String>(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: const Text('Comedy'),
              value: 'Comedy',
              groupValue: _selectedGenre,
              onChanged: (val) => setState(() => _selectedGenre = val),
            ),
            Text(
              'Selected genre: ${_selectedGenre ?? "None"}',
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 24),

            // 4. Date Picker Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF3F4F9),
                  foregroundColor: const Color(0xFF5C6BC0),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: _pickDate,
                child: Text(
                  _selectedDate == null
                      ? 'Open Date Picker'
                      : 'Picked: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

