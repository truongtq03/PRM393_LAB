import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lab8_networking/main.dart';

const postJson = {
  'id': 1,
  'userId': 2,
  'title': 'Hello API',
  'body': 'Full body from API'
};
http.Response loaded() => http.Response(json.encode([postJson]), 200);

void main() {
  Future<void> open(WidgetTester tester, MockClient client) async {
    tester.view.physicalSize = const Size(430, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(client.close);
    await tester.pumpWidget(PostApp(service: ApiService(client: client)));
    await tester.pump();
  }

  testWidgets(
      'loading then loaded list; rebuild does not issue a duplicate GET',
      (tester) async {
    final pending = Completer<http.Response>();
    var calls = 0;
    final client = MockClient((_) {
      calls++;
      return pending.future;
    });
    await open(tester, client);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Loading posts…'), findsOneWidget);
    pending.complete(loaded());
    await tester.pumpAndSettle();
    expect(find.text('Hello API'), findsOneWidget);
    expect(find.text('1 post'), findsOneWidget);
    await tester.pumpWidget(PostApp(service: ApiService(client: client)));
    await tester.pumpAndSettle();
    expect(calls, 1);
  });

  testWidgets('error state exposes retry, then recovers with a fresh request',
      (tester) async {
    var calls = 0;
    await open(
        tester,
        MockClient(
            (_) async => ++calls == 1 ? http.Response('', 503) : loaded()));
    await tester.pumpAndSettle();
    expect(find.text('Could not load posts'), findsOneWidget);
    expect(find.textContaining('HTTP 503'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.text('Hello API'), findsOneWidget);
    expect(calls, 2);
  });

  testWidgets('empty state offers Reload', (tester) async {
    await open(tester, MockClient((_) async => http.Response('[]', 200)));
    await tester.pumpAndSettle();
    expect(find.text('No posts yet'), findsOneWidget);
    expect(find.text('Reload'), findsOneWidget);
  });

  testWidgets(
      'item opens detail with complete model and Back returns to the list',
      (tester) async {
    await open(tester, MockClient((_) async => loaded()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hello API'));
    await tester.pumpAndSettle();
    expect(find.text('Post #1'), findsOneWidget);
    expect(find.text('Full body from API'), findsOneWidget);
    expect(find.text('POST 1 • USER 2'), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('API Posts'), findsOneWidget);
  });

  testWidgets('refresh requests new data and handles a later failure',
      (tester) async {
    var calls = 0;
    await open(
        tester,
        MockClient(
            (_) async => ++calls == 1 ? loaded() : http.Response('', 500)));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Refresh posts'));
    await tester.pumpAndSettle();
    expect(find.text('Could not load posts'), findsOneWidget);
    expect(find.text('Hello API'), findsNothing);
    expect(calls, 2);
  });

  testWidgets(
      'POST validates, blocks duplicate saves, and inserts created item locally',
      (tester) async {
    var postCalls = 0;
    final pending = Completer<http.Response>();
    await open(tester, MockClient((request) {
      if (request.method == 'POST') {
        postCalls++;
        return pending.future;
      }
      return Future.value(loaded());
    }));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('New post'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create post'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a title.'), findsOneWidget);
    expect(find.text('Enter the post body.'), findsOneWidget);
    expect(postCalls, 0);
    await tester.enterText(find.byType(TextFormField).at(0), 'Created title');
    await tester.enterText(find.byType(TextFormField).at(1), 'Created body');
    await tester.tap(find.text('Create post'));
    await tester.pump();
    expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull);
    expect(postCalls, 1);
    pending.complete(http.Response(
        json.encode({
          'id': 101,
          'userId': 1,
          'title': 'Created title',
          'body': 'Created body'
        }),
        201));
    await tester.pumpAndSettle();
    expect(find.text('Created title'), findsOneWidget);
    expect(find.text('Created locally • User 1'), findsOneWidget);
    expect(find.text('2 posts'), findsOneWidget);
  });

  testWidgets('POST failure keeps typed values and permits retry',
      (tester) async {
    await open(
        tester,
        MockClient((request) async =>
            request.method == 'GET' ? loaded() : http.Response('', 500)));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('New post'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'Keep my title');
    await tester.enterText(find.byType(TextFormField).at(1), 'Keep my body');
    await tester.tap(find.text('Create post'));
    await tester.pumpAndSettle();
    expect(find.textContaining('HTTP 500'), findsOneWidget);
    expect(find.text('Keep my title'), findsOneWidget);
    expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNotNull);
  });

  testWidgets('small viewport with keyboard can scroll through the POST form',
      (tester) async {
    await open(tester, MockClient((_) async => loaded()));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('New post'));
    await tester.pumpAndSettle();
    tester.view.physicalSize = const Size(320, 568);
    tester.view.viewInsets = const FakeViewPadding(bottom: 250);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.byType(FilledButton), 100,
        scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
    expect(find.byType(FilledButton).hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
