// Deterministic screenshot harness. Production lib/main.dart always uses the API.
// flutter run -d chrome -t tool/state_preview.dart
// Add ?scenario=loading or ?scenario=error to the preview URL.
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import '../lib/main.dart';

void main() {
  final scenario = Uri.base.queryParameters['scenario'];
  if (scenario == 'loading' || scenario == 'error') {
    final client = MockClient((_) async {
      if (scenario == 'loading') {
        await Future<void>.delayed(const Duration(minutes: 2));
        return http.Response('[]', 200);
      }
      return http.Response('', 503);
    });
    runApp(PostApp(
        service:
            ApiService(client: client, timeout: const Duration(minutes: 3))));
  } else {
    runApp(const PostApp());
  }
}
