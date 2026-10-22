// Screenshot helper: main app always calls the real APIs.
// flutter run -d chrome -t tool/state_preview.dart
// ?scenario=loading or ?scenario=error
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import '../lib/main.dart';
import '../lib/services/weather_service.dart';

void main() {
  final scenario = Uri.base.queryParameters['scenario'];
  if (scenario == 'loading' || scenario == 'error') {
    final client = MockClient((_) async {
      if (scenario == 'loading')
        await Future<void>.delayed(const Duration(minutes: 2));
      return http.Response('', 503);
    });
    runApp(WeatherApp(
        service: WeatherService(
            client: client, timeout: const Duration(minutes: 3))));
  } else {
    runApp(const WeatherApp());
  }
}
