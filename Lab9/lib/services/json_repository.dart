import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/local_item.dart';
import 'json_backend.dart';

class StorageException implements Exception {
  final String message;
  const StorageException(this.message);
  @override
  String toString() => message;
}

class AssetItemService {
  final AssetBundle bundle;
  AssetItemService({AssetBundle? bundle}) : bundle = bundle ?? rootBundle;
  Future<List<LocalItem>> load() async {
    final content = await bundle.loadString('assets/data/items.json');
    return parseItems(jsonDecode(content));
  }
}

class JsonRepository {
  final JsonBackend backend;
  final String filename;
  JsonRepository({required this.backend, required this.filename});

  Future<ItemDatabase> load() async {
    try {
      final content = await backend.read(filename);
      if (content == null) {
        final empty = ItemDatabase.empty();
        await save(empty);
        return empty;
      }
      final decoded = jsonDecode(content);
      if (decoded is! Map<String, dynamic>)
        throw const FormatException('Expected a database.');
      return ItemDatabase.fromJson(decoded);
    } on FormatException {
      // A damaged file is never replaced with an empty list automatically.
      throw const StorageException(
          'JSON không hợp lệ. Dữ liệu gốc được giữ nguyên; kiểm tra tệp rồi tải lại.');
    } on StorageException {
      rethrow;
    } catch (_) {
      throw const StorageException(
          'Không đọc được dữ liệu. Kiểm tra quyền truy cập hoặc dung lượng rồi thử lại.');
    }
  }

  Future<void> save(ItemDatabase database) async {
    try {
      // Validate before touching storage, including duplicate IDs and metadata.
      ItemDatabase.fromJson(database.toJson());
      await backend.write(filename, database.encode());
    } catch (_) {
      throw const StorageException(
          'Chưa lưu được dữ liệu. Hãy thử lại; thay đổi chưa được xác nhận lưu.');
    }
  }

  Future<String> location() => backend.location(filename);
}
