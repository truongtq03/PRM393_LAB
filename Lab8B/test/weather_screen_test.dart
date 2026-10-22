import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lab8b_weather/main.dart';
import 'package:lab8b_weather/services/weather_service.dart';
import 'package:lab8b_weather/widgets/weather_widgets.dart';
import 'fixtures.dart';

http.Response weatherResponse({double temperature = 26}) => http.Response.bytes(
    utf8.encode(json.encode(weatherJson(temperature: temperature))), 200);

void main() {
  Future<void> open(WidgetTester tester, MockClient client,
      {Size size = const Size(430, 1100)}) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(client.close);
    await tester
        .pumpWidget(WeatherApp(service: WeatherService(client: client)));
    await tester.pump();
  }

  testWidgets(
      'loading becomes real model UI with useful recommendations and no duplicate GET',
      (tester) async {
    var calls = 0;
    final pending = Completer<http.Response>();
    final client = MockClient((_) {
      calls++;
      return pending.future;
    });
    await open(tester, client);
    expect(find.textContaining('Đang tải thời tiết'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    pending.complete(weatherResponse());
    await tester.pumpAndSettle();
    expect(find.text('26°C'), findsOneWidget);
    expect(find.text('Chuẩn bị cho hôm nay'), findsOneWidget);
    expect(find.text('Khả năng mưa thấp'), findsOneWidget);
    await tester
        .pumpWidget(WeatherApp(service: WeatherService(client: client)));
    await tester.pumpAndSettle();
    expect(calls, 1);
  });

  testWidgets('weather error retries and recovers', (tester) async {
    var calls = 0;
    await open(
        tester,
        MockClient((_) async =>
            ++calls == 1 ? http.Response('', 503) : weatherResponse()));
    await tester.pumpAndSettle();
    expect(find.text('Chưa tải được thời tiết'), findsOneWidget);
    await tester.tap(find.text('Thử lại'));
    await tester.pumpAndSettle();
    expect(find.text('26°C'), findsOneWidget);
    expect(calls, 2);
  });

  testWidgets('search validates then shows an empty state for unmatched cities',
      (tester) async {
    var searches = 0;
    await open(tester, MockClient((request) async {
      if (request.url.host.startsWith('geocoding')) {
        searches++;
        return http.Response('{}', 200);
      }
      return weatherResponse();
    }));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Tìm địa điểm'));
    await tester.pumpAndSettle();
    expect(find.text('Nhập ít nhất 2 ký tự.'), findsOneWidget);
    expect(searches, 0);
    await tester.enterText(find.byType(TextFormField), 'unknowncity');
    await tester.tap(find.byTooltip('Tìm địa điểm'));
    await tester.pumpAndSettle();
    expect(find.text('Không có kết quả'), findsOneWidget);
    expect(searches, 1);
  });

  testWidgets('search returns models, selection fetches the chosen coordinates',
      (tester) async {
    await open(tester, MockClient((request) async {
      if (request.url.host.startsWith('geocoding')) {
        return http.Response(
            json.encode({
              'results': [cityJson]
            }),
            200);
      }
      return weatherResponse(
          temperature:
              request.url.queryParameters['latitude'] == '51.5' ? 12 : 26);
    }));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'London');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, 'London'));
    await tester.pumpAndSettle();
    expect(find.text('12°C'), findsOneWidget);
    expect(find.text('London'), findsOneWidget);
    expect(
        tester
            .widget<TextFormField>(find.byType(TextFormField))
            .controller!
            .text,
        '');
  });

  testWidgets('search error offers retry without discarding current weather',
      (tester) async {
    var attempts = 0;
    await open(tester, MockClient((request) async {
      if (request.url.host.startsWith('geocoding')) {
        return ++attempts == 1
            ? http.Response('', 500)
            : http.Response('{"results":[]}', 200);
      }
      return weatherResponse();
    }));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'London');
    await tester.tap(find.byTooltip('Tìm địa điểm'));
    await tester.pumpAndSettle();
    expect(find.text('Không tìm được địa điểm'), findsOneWidget);
    expect(find.text('26°C'), findsOneWidget);
    await tester.tap(find.text('Thử lại'));
    await tester.pumpAndSettle();
    expect(find.text('Không có kết quả'), findsOneWidget);
    expect(attempts, 2);
  });

  testWidgets(
      'changing city ignores late results from the previously selected city',
      (tester) async {
    final first = Completer<http.Response>();
    await open(
        tester,
        MockClient((request) =>
            request.url.queryParameters['latitude'] == '10.8231'
                ? first.future
                : Future.value(weatherResponse(temperature: 19))));
    await tester.tap(find.widgetWithText(ChoiceChip, 'Hà Nội'));
    await tester.pumpAndSettle();
    expect(find.text('19°C'), findsOneWidget);
    first.complete(weatherResponse(temperature: 32));
    await tester.pumpAndSettle();
    expect(find.text('19°C'), findsOneWidget);
    expect(find.text('32°C'), findsNothing);
  });

  testWidgets('empty forecast shows a reloadable state', (tester) async {
    final data = weatherJson();
    final daily = data['daily'] as Map;
    for (final key in daily.keys.toList()) {
      daily[key] = [];
    }
    await open(
        tester, MockClient((_) async => http.Response(json.encode(data), 200)));
    await tester.pumpAndSettle();
    expect(find.text('Chưa có dữ liệu dự báo'), findsOneWidget);
    expect(find.text('Thử lại'), findsOneWidget);
  });

  for (final size in [const Size(320, 568), const Size(1024, 1000)]) {
    testWidgets(
        'current weather, recommendations and forecast scroll without overflow at $size',
        (tester) async {
      await open(tester, MockClient((_) async => weatherResponse()),
          size: size);
      await tester.pumpAndSettle();
      expect(find.byType(WeatherDashboard), findsOneWidget);
      await tester.scrollUntilVisible(find.text('Dự báo 3 ngày'), 150,
          scrollable: find.byType(Scrollable).first);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
