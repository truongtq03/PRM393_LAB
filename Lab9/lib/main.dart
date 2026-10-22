import 'package:flutter/material.dart';
import 'screens/asset_screen.dart';
import 'screens/storage_screen.dart';
import 'services/json_backend.dart';
import 'services/json_repository.dart';
import 'services/platform_backend.dart';

void main() => runApp(const JsonLabApp());

class JsonLabApp extends StatelessWidget {
  final JsonBackend? backend;
  const JsonLabApp({super.key, this.backend});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Lab 9 • Local JSON',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            useMaterial3: true,
            colorScheme:
                ColorScheme.fromSeed(seedColor: const Color(0xFF305B9C)),
            scaffoldBackgroundColor: const Color(0xFFF4F6FA),
            inputDecorationTheme: const InputDecorationTheme(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder())),
        home: JsonLabHome(backend: backend ?? createBackend()),
      );
}

class JsonLabHome extends StatefulWidget {
  final JsonBackend backend;
  const JsonLabHome({super.key, required this.backend});
  @override
  State<JsonLabHome> createState() => _JsonLabHomeState();
}

class _JsonLabHomeState extends State<JsonLabHome> {
  int _index = 0;
  late final _manual =
      JsonRepository(backend: widget.backend, filename: 'manual_saved.json');
  late final _crud =
      JsonRepository(backend: widget.backend, filename: 'crud_database.json');

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Lab 9 • Local JSON')),
        body: SafeArea(
            child: Center(
                child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: IndexedStack(index: _index, children: [
            const AssetScreen(),
            StorageScreen(repository: _manual, autoSave: false),
            StorageScreen(repository: _crud, autoSave: true),
          ]),
        ))),
        bottomNavigationBar: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (index) => setState(() {
                  _index = index;
                }),
            destinations: const [
              NavigationDestination(
                  icon: Icon(Icons.source_outlined), label: '9.1 Assets'),
              NavigationDestination(
                  icon: Icon(Icons.save_outlined), label: '9.2 Save/Load'),
              NavigationDestination(
                  icon: Icon(Icons.edit_note), label: '9.3 CRUD'),
            ]),
      );
}
