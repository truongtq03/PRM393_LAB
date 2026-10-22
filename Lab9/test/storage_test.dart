import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:lab9_json_storage/models/local_item.dart';
import 'package:lab9_json_storage/services/json_repository.dart';
import 'package:lab9_json_storage/services/platform_backend_io.dart';
import 'memory_backend.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('real bundled asset JSON loads into models with at least two fields',
      () async {
    final items = await AssetItemService().load();
    expect(items.length, 4);
    expect(items.first.id, 1);
    expect(items.first.name, 'Flutter UI Fundamentals');
    expect(items.first.description, contains('Lab 4'));
  });

  test('model JSON round trip, immutable CRUD, search, and IDs not reused', () {
    final initial = ItemDatabase.empty();
    final added = initial.add('  Flutter ', ' JSON notes ');
    final second = added.add('Dart', 'Practice');
    expect(initial.items, isEmpty);
    expect(added.items.single.name, 'Flutter');
    expect(second.search(' FLUTTER ').single.id, 1);
    expect(second.search('practice').single.id, 2);
    expect(second.search('2').single.name, 'Dart');
    final edited = second.update(1, 'Updated', 'new note');
    expect(edited.items.first.name, 'Updated');
    expect(second.items.first.name, 'Flutter');
    final deleted = edited.delete(2);
    expect(deleted.add('Third', '').items.last.id, 3);
    expect(
        ItemDatabase.fromJson(
                jsonDecode(edited.encode()) as Map<String, dynamic>)
            .items
            .first
            .name,
        'Updated');
  });

  test('parsing rejects malformed fields, duplicate IDs and invalid counters',
      () {
    expect(() => LocalItem.fromJson({'id': 0, 'name': 'A', 'description': ''}),
        throwsFormatException);
    expect(() => LocalItem.fromJson({'id': 1, 'name': ' ', 'description': ''}),
        throwsFormatException);
    final item = {'id': 1, 'name': 'A', 'description': ''};
    expect(() => parseItems([item, item]), throwsFormatException);
    expect(
        () => ItemDatabase.fromJson({
              'version': 2,
              'nextId': 2,
              'items': [item]
            }),
        throwsFormatException);
    expect(
        () => ItemDatabase.fromJson({
              'version': 1,
              'nextId': 1,
              'items': [item]
            }),
        throwsFormatException);
  });

  test('missing storage is initialized and two labs have isolated databases',
      () async {
    final backend = MemoryBackend();
    final first =
        JsonRepository(backend: backend, filename: 'manual_saved.json');
    final second =
        JsonRepository(backend: backend, filename: 'crud_database.json');
    expect((await first.load()).items, isEmpty);
    expect(backend.data['manual_saved.json'], isNotNull);
    await first.save(ItemDatabase.empty().add('Manual item', ''));
    expect((await second.load()).items, isEmpty);
    expect((await first.load()).items.single.name, 'Manual item');
  });

  test('corrupt JSON is reported and never silently replaced', () async {
    final backend = MemoryBackend();
    backend.data['broken.json'] = '{not valid JSON';
    final repository =
        JsonRepository(backend: backend, filename: 'broken.json');
    await expectLater(repository.load(), throwsA(isA<StorageException>()));
    expect(backend.data['broken.json'], '{not valid JSON');
  });

  test('failed writes preserve previous stored JSON and report failure',
      () async {
    final backend = MemoryBackend();
    final repository = JsonRepository(backend: backend, filename: 'items.json');
    final initial = await repository.load();
    final saved = backend.data['items.json'];
    backend.failWrites = true;
    await expectLater(repository.save(initial.add('Not saved', '')),
        throwsA(isA<StorageException>()));
    expect(backend.data['items.json'], saved);
  });

  test(
      'real files survive new repository instances and support overwrite/edit/delete',
      () async {
    final directory =
        await Directory.systemTemp.createTemp('prm393_lab9_test_');
    addTearDown(() async {
      final prefix =
          '${Directory.systemTemp.absolute.path}${Platform.pathSeparator}prm393_lab9_test_';
      if (!directory.absolute.path.startsWith(prefix))
        throw StateError('Unexpected cleanup target');
      await directory.delete(recursive: true);
    });
    JsonRepository repository() => JsonRepository(
        filename: 'database.json',
        backend: FileJsonBackend(documentsDirectory: () async => directory));
    final first = repository();
    var database = await first.load();
    final path = await first.location();
    expect(await File(path).exists(), isTrue);
    database = database.add('Tiếng Việt được lưu', 'Đọc sau khi mở lại');
    await first.save(database);
    final restarted = repository();
    expect((await restarted.load()).items.single.name, 'Tiếng Việt được lưu');
    await restarted
        .save((await restarted.load()).update(1, 'Đã sửa', 'New note'));
    expect((await repository().load()).items.single.name, 'Đã sửa');
    await repository().save((await repository().load()).delete(1));
    expect((await repository().load()).items, isEmpty);
    expect((await repository().load()).add('Next', '').items.single.id, 2);
    expect(await File('$path.tmp').exists(), isFalse);
    final raw = jsonDecode(await File(path).readAsString()) as Map;
    expect(raw['nextId'], 2);
  });

  test('native backend rejects filenames that escape its directory', () async {
    final backend =
        FileJsonBackend(documentsDirectory: () async => Directory.systemTemp);
    await expectLater(backend.read('../other.json'), throwsArgumentError);
    await expectLater(backend.write('invalid.txt', '{}'), throwsArgumentError);
  });
}
