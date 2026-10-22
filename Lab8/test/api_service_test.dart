import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lab8_networking/main.dart';

const postJson = {
  'id': 1,
  'userId': 2,
  'title': 'Hello API',
  'body': 'Post body'
};

void main() {
  test('model maps all fields and rejects missing or incorrect field types',
      () {
    final post = Post.fromJson(postJson);
    expect([post.id, post.userId, post.title, post.body],
        [1, 2, 'Hello API', 'Post body']);
    expect(() => Post.fromJson({'id': 1}), throwsFormatException);
    expect(
        () => Post.fromJson({...postJson, 'id': '1'}), throwsFormatException);
  });

  test('GET uses the correct endpoint and parses UTF-8 into models', () async {
    final service = ApiService(client: MockClient((request) async {
      expect(request.method, 'GET');
      expect(request.url, ApiService.postsUri);
      return http.Response.bytes(
          utf8.encode(json.encode([
            {...postJson, 'title': 'Bài viết tiếng Việt'},
            postJson,
          ])),
          200);
    }));
    addTearDown(service.close);
    final posts = await service.fetchPosts();
    expect(posts.length, 2);
    expect(posts.first.title, 'Bài viết tiếng Việt');
  });

  test('empty API array returns an empty model list', () async {
    final service =
        ApiService(client: MockClient((_) async => http.Response('[]', 200)));
    addTearDown(service.close);
    expect(await service.fetchPosts(), isEmpty);
  });

  for (final body in ['not json', '{}', '[1]', '[{"id":1}]']) {
    test('invalid API payload is reported as a friendly error: $body',
        () async {
      final service =
          ApiService(client: MockClient((_) async => http.Response(body, 200)));
      addTearDown(service.close);
      await expectLater(
          service.fetchPosts(),
          throwsA(isA<ApiException>()
              .having((e) => e.message, 'message', contains('invalid data'))));
    });
  }

  test(
      'HTTP errors preserve the status without exposing server response bodies',
      () async {
    final service = ApiService(
        client: MockClient((_) async => http.Response('private details', 503)));
    addTearDown(service.close);
    await expectLater(
        service.fetchPosts(),
        throwsA(isA<ApiException>()
            .having((e) => e.message, 'message', contains('HTTP 503'))));
  });

  test('client failures become connection errors', () async {
    final service = ApiService(
        client: MockClient((_) async => throw http.ClientException('offline')));
    addTearDown(service.close);
    await expectLater(
        service.fetchPosts(),
        throwsA(isA<ApiException>().having(
            (e) => e.message, 'message', contains('Check your internet'))));
  });

  test('timeout is handled separately from server errors', () async {
    final pending = Completer<http.Response>();
    final service = ApiService(
        client: MockClient((_) => pending.future),
        timeout: const Duration(milliseconds: 10));
    addTearDown(service.close);
    await expectLater(
        service.fetchPosts(),
        throwsA(isA<ApiException>()
            .having((e) => e.message, 'message', contains('timed out'))));
    pending.complete(http.Response('[]', 200));
  });

  test('POST sends trimmed JSON, validates status 201, and parses the result',
      () async {
    final service = ApiService(client: MockClient((request) async {
      expect(request.method, 'POST');
      expect(request.url, ApiService.postsUri);
      expect(request.headers['content-type'], contains('application/json'));
      expect(json.decode(request.body),
          {'title': 'New title', 'body': 'New body', 'userId': 1});
      return http.Response(
          json.encode({'id': 101, ...json.decode(request.body) as Map}), 201);
    }));
    addTearDown(service.close);
    final post =
        await service.createPost(title: '  New title ', body: ' New body  ');
    expect(post.id, 101);
    expect(post.title, 'New title');
  });

  test('POST rejects non-success and malformed success responses', () async {
    for (final response in [
      http.Response('{}', 400),
      http.Response('[]', 201)
    ]) {
      final service = ApiService(client: MockClient((_) async => response));
      await expectLater(service.createPost(title: 'A', body: 'B'),
          throwsA(isA<ApiException>()));
      service.close();
    }
  });
}
