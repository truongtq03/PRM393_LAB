abstract class JsonBackend {
  Future<String?> read(String filename);
  Future<void> write(String filename, String content);
  Future<String> location(String filename);
}

void validateFilename(String filename) {
  if (!RegExp(r'^[a-z0-9_]+\.json$').hasMatch(filename)) {
    throw ArgumentError('Use a simple JSON filename.');
  }
}
