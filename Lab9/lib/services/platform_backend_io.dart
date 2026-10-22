import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'json_backend.dart';

JsonBackend createBackend() => FileJsonBackend();

class FileJsonBackend implements JsonBackend {
  final Future<Directory> Function() _documentsDirectory;
  FileJsonBackend({Future<Directory> Function()? documentsDirectory})
      : _documentsDirectory =
            documentsDirectory ?? getApplicationDocumentsDirectory;

  Future<File> _file(String filename) async {
    validateFilename(filename);
    final documents = await _documentsDirectory();
    final folder =
        Directory('${documents.path}${Platform.pathSeparator}PRM393_Lab9');
    await folder.create(recursive: true);
    return File('${folder.path}${Platform.pathSeparator}$filename');
  }

  @override
  Future<String?> read(String filename) async {
    final file = await _file(filename);
    return await file.exists() ? file.readAsString() : null;
  }

  @override
  Future<void> write(String filename, String content) async {
    final file = await _file(filename);
    // Write/flush a temporary sibling before replacing the previous file.
    final temporary = File('${file.path}.tmp');
    await temporary.writeAsString(content, flush: true);
    await temporary.rename(file.path);
  }

  @override
  Future<String> location(String filename) async =>
      (await _file(filename)).path;
}
