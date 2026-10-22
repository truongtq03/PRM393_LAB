import 'package:lab9_json_storage/services/json_backend.dart';

class MemoryBackend implements JsonBackend {
  final data = <String, String>{};
  bool failWrites = false;
  bool failReads = false;
  @override
  Future<String?> read(String filename) async {
    if (failReads) throw StateError('Test read failure');
    return data[filename];
  }

  @override
  Future<void> write(String filename, String content) async {
    if (failWrites) throw StateError('Test write failure');
    data[filename] = content;
  }

  @override
  Future<String> location(String filename) async => 'Test storage • $filename';
}
