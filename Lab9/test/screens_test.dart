import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lab9_json_storage/main.dart';
import 'package:lab9_json_storage/models/local_item.dart';
import 'memory_backend.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  Future<void> open(WidgetTester tester, MemoryBackend backend) async {
    tester.view.physicalSize = const Size(430, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    // Asset platform messages use real IO; finish them outside fake async.
    await tester.runAsync(() async {
      await rootBundle.loadString('assets/data/items.json');
      await tester.pumpWidget(JsonLabApp(backend: backend));
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();
  }

  Future<void> tab(WidgetTester tester, String name) async {
    await tester.tap(find.text(name));
    await tester.pumpAndSettle();
  }

  Future<void> add(WidgetTester tester, String name) async {
    await tester.tap(find.text('Thêm mục').hitTestable());
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, name);
    await tester.enterText(find.byType(TextFormField).last, 'Saved note');
    await tester.tap(find.text('Thêm'));
    await tester.pumpAndSettle();
  }

  testWidgets('asset screen shows real bundled data', (tester) async {
    await open(tester, MemoryBackend());
    expect(find.text('Flutter UI Fundamentals'), findsOneWidget);
    expect(find.text('Networking and JSON'), findsOneWidget);
    expect(find.text('assets/data/items.json'), findsOneWidget);
  });

  testWidgets(
      'manual add remains unsaved until Save; reload restores saved data',
      (tester) async {
    final backend = MemoryBackend();
    await open(tester, backend);
    await tab(tester, '9.2 Save/Load');
    await add(tester, 'My saved item');
    expect(find.text('Có thay đổi chưa lưu'), findsOneWidget);
    expect((jsonDecode(backend.data['manual_saved.json']!) as Map)['items'],
        isEmpty);
    await tester.tap(find.text('Lưu JSON'));
    await tester.pumpAndSettle();
    expect((jsonDecode(backend.data['manual_saved.json']!) as Map)['items'],
        hasLength(1));
    await add(tester, 'Unsaved item');
    await tester.tap(find.text('Tải lại'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tải lại').last);
    await tester.pumpAndSettle();
    expect(find.text('My saved item'), findsOneWidget);
    expect(find.text('Unsaved item'), findsNothing);
  });

  testWidgets('manual saved content survives recreating the entire app',
      (tester) async {
    final backend = MemoryBackend();
    await open(tester, backend);
    await tab(tester, '9.2 Save/Load');
    await add(tester, 'Across restarts');
    await tester.tap(find.text('Lưu JSON'));
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox());
    await open(tester, backend);
    await tab(tester, '9.2 Save/Load');
    expect(find.text('Across restarts'), findsOneWidget);
  });

  testWidgets('CRUD adds, searches, edits and confirms deletion with auto-save',
      (tester) async {
    final backend = MemoryBackend();
    await open(tester, backend);
    await tab(tester, '9.3 CRUD');
    await add(tester, 'Flutter study');
    expect((jsonDecode(backend.data['crud_database.json']!) as Map)['items'],
        hasLength(1));
    await tester.enterText(find.byType(TextField).hitTestable(), 'no match');
    await tester.pumpAndSettle();
    expect(find.text('Không có kết quả phù hợp.'), findsOneWidget);
    await tester.enterText(find.byType(TextField).hitTestable(), 'FLUTTER');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sửa'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Flutter updated');
    await tester.tap(find.text('Lưu thay đổi'));
    await tester.pumpAndSettle();
    expect(find.text('Flutter updated'), findsOneWidget);
    expect(
        ((jsonDecode(backend.data['crud_database.json']!) as Map)['items']
                as List)
            .single['name'],
        'Flutter updated');
    await tester.tap(find.text('Xóa'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hủy'));
    await tester.pumpAndSettle();
    expect(find.text('Flutter updated'), findsOneWidget);
    await tester.tap(find.text('Xóa'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Xóa').last);
    await tester.pumpAndSettle();
    expect((jsonDecode(backend.data['crud_database.json']!) as Map)['items'],
        isEmpty);
  });

  testWidgets('failed CRUD write does not present an unpersisted item as saved',
      (tester) async {
    final backend = MemoryBackend();
    await open(tester, backend);
    await tab(tester, '9.3 CRUD');
    backend.failWrites = true;
    await add(tester, 'Will fail');
    expect(find.textContaining('Chưa lưu được dữ liệu.'), findsOneWidget);
    expect(find.text('Will fail'), findsNothing);
    expect((jsonDecode(backend.data['crud_database.json']!) as Map)['items'],
        isEmpty);
  });

  testWidgets(
      'corrupt stored JSON displays retry and leaves original contents intact',
      (tester) async {
    final backend = MemoryBackend();
    backend.data['crud_database.json'] = 'broken';
    await open(tester, backend);
    await tab(tester, '9.3 CRUD');
    expect(find.textContaining('JSON không hợp lệ'), findsOneWidget);
    expect(backend.data['crud_database.json'], 'broken');
    backend.data['crud_database.json'] = ItemDatabase.empty().encode();
    await tester.tap(find.text('Thử lại'));
    await tester.pumpAndSettle();
    expect(find.text('0 / 0 mục'), findsOneWidget);
  });

  testWidgets(
      'editor validates empty names and storage JSON preview shows saved data',
      (tester) async {
    await open(tester, MemoryBackend());
    await tab(tester, '9.3 CRUD');
    await tester.tap(find.text('Thêm mục').hitTestable());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Thêm'));
    await tester.pumpAndSettle();
    expect(find.text('Vui lòng nhập tên mục.'), findsOneWidget);
    await tester.tap(find.text('Hủy'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Xem JSON đã lưu'));
    await tester.pumpAndSettle();
    expect(find.textContaining('"nextId": 1'), findsOneWidget);
  });

  testWidgets(
      'CRUD on small viewport with keyboard can scroll without overflow',
      (tester) async {
    await open(tester, MemoryBackend());
    await tab(tester, '9.3 CRUD');
    tester.view.physicalSize = const Size(320, 568);
    tester.view.viewInsets = const FakeViewPadding(bottom: 220);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpAndSettle();
    await tester.drag(
        find.byType(ListView).hitTestable(), const Offset(0, -250));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
