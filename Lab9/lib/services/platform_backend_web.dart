import 'package:web/web.dart' as web;
import 'json_backend.dart';

JsonBackend createBackend() => BrowserJsonBackend();

// Extra web support only: the required File/path_provider implementation is native.
class BrowserJsonBackend implements JsonBackend {
  String _key(String filename) {
    validateFilename(filename);
    return 'prm393_lab9_$filename';
  }

  @override
  Future<String?> read(String filename) async =>
      web.window.localStorage.getItem(_key(filename));
  @override
  Future<void> write(String filename, String content) async =>
      web.window.localStorage.setItem(_key(filename), content);
  @override
  Future<String> location(String filename) async =>
      'Web localStorage • ${_key(filename)}';
}
