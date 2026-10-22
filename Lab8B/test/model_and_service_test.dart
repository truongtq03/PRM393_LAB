import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lab8b_weather/models/weather.dart';
import 'package:lab8b_weather/services/weather_service.dart';
import 'fixtures.dart';

void main() {
  test(
      'city maps coordinates, region, country and supports missing optional fields',
      () {
    final city = City.fromJson(cityJson);
    expect(city.name, 'London');
    expect(city.subtitle, 'England, United Kingdom');
    expect(city.longitude, -0.12);
    expect(City.fromJson({'name': 'A', 'latitude': 0, 'longitude': 0}).subtitle,
        '');
    expect(() => City.fromJson({...cityJson, 'latitude': 100}),
        throwsFormatException);
    expect(() => City.fromJson({...cityJson, 'longitude': '0'}),
        throwsFormatException);
  });

  test('weather maps typed current values and daily parallel arrays', () {
    final report = WeatherReport.fromJson(weatherJson());
    expect(report.current.temperature, 26);
    expect(report.current.humidity, 65);
    expect(report.days.length, 3);
    expect(report.days.first.date.day, 22);
    expect(report.days.first.rainChance, 10);
    expect(report.timezone, 'Asia/Ho_Chi_Minh');
  });

  test('null probability stays unknown instead of becoming zero', () {
    final report = WeatherReport.fromJson(weatherJson(rainChance: null));
    expect(report.days.first.rainChance, isNull);
    expect(WeatherAdvice.forReport(report).umbrella.title,
        'Kiểm tra mưa trước khi đi');
  });

  test(
      'malformed, non-finite, mismatched and out-of-range weather are rejected',
      () {
    expect(() => WeatherReport.fromJson({}), throwsFormatException);
    final data = weatherJson();
    (data['daily'] as Map)['time'] = ['2026-10-22'];
    expect(() => WeatherReport.fromJson(data), throwsFormatException);
    final invalidCurrent = weatherJson();
    (invalidCurrent['current'] as Map)['relative_humidity_2m'] = 101;
    expect(() => WeatherReport.fromJson(invalidCurrent), throwsFormatException);
    expect(() => readNumber(double.nan), throwsFormatException);
    expect(() => readInt(1.5), throwsFormatException);
    expect(() => WeatherReport.fromJson(weatherJson(high: 15)),
        throwsFormatException);
  });

  test('rain chance boundary, wet WMO codes, heat and wind drive useful advice',
      () {
    final dry = WeatherAdvice.forReport(
        WeatherReport.fromJson(weatherJson(rainChance: 39)));
    expect(dry.umbrella.title, 'Khả năng mưa thấp');
    final rain = WeatherAdvice.forReport(
        WeatherReport.fromJson(weatherJson(rainChance: 40)));
    expect(rain.umbrella.title, 'Nên mang ô hoặc áo mưa');
    expect(rain.outdoor.title, 'Lên phương án trong nhà');
    final drizzle =
        WeatherAdvice.forReport(WeatherReport.fromJson(weatherJson(code: 51)));
    expect(drizzle.umbrella.title, 'Nên mang ô hoặc áo mưa');
    final hot = WeatherAdvice.forReport(
        WeatherReport.fromJson(weatherJson(feelsLike: 35)));
    expect(hot.clothing.title, 'Chọn trang phục thoáng nhẹ');
    expect(hot.outdoor.title, 'Tránh vận động giữa trưa');
    final windy =
        WeatherAdvice.forReport(WeatherReport.fromJson(weatherJson(wind: 35)));
    expect(windy.outdoor.title, 'Chọn nơi kín gió');
  });

  test(
      'storm advice takes priority over heat and low chance; unknown code is described',
      () {
    final storm = WeatherAdvice.forReport(WeatherReport.fromJson(
        weatherJson(code: 95, dailyCode: 95, feelsLike: 38, rainChance: 5)));
    expect(storm.outdoor.title, 'Ưu tiên hoạt động trong nhà');
    expect(weatherDescription(95), 'Dông');
    expect(weatherDescription(999), contains('Chưa rõ'));
    final unknown =
        WeatherAdvice.forReport(WeatherReport.fromJson(weatherJson(code: 999)));
    expect(unknown.outdoor.title, 'Kiểm tra điều kiện trước khi đi');
  });

  test('search uses GET with encoded query and maps UTF-8 city models',
      () async {
    final service = WeatherService(client: MockClient((request) async {
      expect(request.method, 'GET');
      expect(request.url.host, 'geocoding-api.open-meteo.com');
      expect(request.url.queryParameters['name'], 'Hà Nội');
      expect(request.url.queryParameters['language'], 'vi');
      return http.Response.bytes(
          utf8.encode(json.encode({
            'results': [
              {...cityJson, 'name': 'Hà Nội'}
            ]
          })),
          200);
    }));
    addTearDown(service.close);
    expect((await service.searchCities(' Hà Nội ')).first.name, 'Hà Nội');
  });

  test(
      'empty geocoding response means no results; short query sends no request',
      () async {
    var requests = 0;
    final service = WeatherService(client: MockClient((_) async {
      requests++;
      return http.Response('{}', 200);
    }));
    addTearDown(service.close);
    expect(await service.searchCities('a'), isEmpty);
    expect(requests, 0);
    expect(await service.searchCities('zzzzzz'), isEmpty);
    expect(requests, 1);
  });

  test(
      'forecast request sets location, local timezone, forecast days and units',
      () async {
    final service = WeatherService(client: MockClient((request) async {
      expect(request.url.host, 'api.open-meteo.com');
      expect(request.url.queryParameters['latitude'],
          '${presetCities.first.latitude}');
      expect(request.url.queryParameters['timezone'], 'auto');
      expect(request.url.queryParameters['forecast_days'], '3');
      expect(request.url.queryParameters['wind_speed_unit'], 'kmh');
      expect(request.url.queryParameters['daily'],
          contains('precipitation_probability_max'));
      return http.Response(json.encode(weatherJson()), 200);
    }));
    addTearDown(service.close);
    expect((await service.fetchWeather(presetCities.first)).days.length, 3);
  });

  for (final response in [
    http.Response('oops', 200),
    http.Response('[]', 200),
    http.Response('{"error":true}', 200),
    http.Response('{}', 200),
    http.Response('', 503)
  ]) {
    test(
        'forecast rejects bad payload or HTTP ${response.statusCode}: ${response.body}',
        () async {
      final service = WeatherService(client: MockClient((_) async => response));
      addTearDown(service.close);
      await expectLater(service.fetchWeather(presetCities.first),
          throwsA(isA<WeatherException>()));
    });
  }

  test('malformed search results produce a friendly error', () async {
    final service = WeatherService(
        client: MockClient((_) async => http.Response('{"results":[1]}', 200)));
    addTearDown(service.close);
    await expectLater(
        service.searchCities('London'), throwsA(isA<WeatherException>()));
  });

  test('client failures and timeouts become readable errors', () async {
    final offline = WeatherService(
        client: MockClient((_) async => throw http.ClientException('offline')));
    await expectLater(
        offline.fetchWeather(presetCities.first),
        throwsA(isA<WeatherException>()
            .having((e) => e.message, 'message', contains('Internet'))));
    offline.close();
    final completer = Completer<http.Response>();
    final service = WeatherService(
        client: MockClient((_) => completer.future),
        timeout: const Duration(milliseconds: 10));
    addTearDown(service.close);
    await expectLater(
        service.fetchWeather(presetCities.first),
        throwsA(isA<WeatherException>()
            .having((e) => e.message, 'message', contains('thời gian chờ'))));
    completer.complete(http.Response('{}', 200));
  });
}
