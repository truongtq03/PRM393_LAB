import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather.dart';

class WeatherException implements Exception {
  final String message;
  const WeatherException(this.message);
  @override
  String toString() => message;
}

// All HTTP lives here; screens receive typed models, never raw JSON maps.
class WeatherService {
  final http.Client _client;
  final Duration timeout;
  WeatherService(
      {http.Client? client, this.timeout = const Duration(seconds: 15)})
      : _client = client ?? http.Client();

  Future<Map<String, dynamic>> _get(Uri uri) async {
    try {
      final response = await _client.get(uri).timeout(timeout);
      if (response.statusCode != 200) {
        throw WeatherException(
            'Dịch vụ trả về HTTP ${response.statusCode}. Vui lòng thử lại.');
      }
      final data = json.decode(utf8.decode(response.bodyBytes));
      if (data is! Map<String, dynamic> || data['error'] == true) {
        throw const FormatException('Unexpected API response.');
      }
      return data;
    } on TimeoutException {
      throw const WeatherException(
          'Kết nối quá thời gian chờ. Vui lòng thử lại.');
    } on http.ClientException {
      throw const WeatherException(
          'Không kết nối được. Kiểm tra Internet và thử lại.');
    } on FormatException {
      throw const WeatherException(
          'Dịch vụ trả về dữ liệu không hợp lệ. Vui lòng thử lại.');
    }
  }

  Future<List<City>> searchCities(String query) async {
    final trimmed = query.trim();
    if (trimmed.length < 2) return [];
    final data = await _get(Uri.https(
        'geocoding-api.open-meteo.com',
        '/v1/search',
        {'name': trimmed, 'count': '8', 'language': 'vi', 'format': 'json'}));
    try {
      if (!data.containsKey('results')) return [];
      final results = data['results'];
      if (results is! List) throw const FormatException('Expected cities.');
      return results.map((item) {
        if (item is! Map<String, dynamic>)
          throw const FormatException('Invalid city.');
        return City.fromJson(item);
      }).toList();
    } on FormatException {
      throw const WeatherException(
          'Dữ liệu địa điểm không hợp lệ. Vui lòng thử lại.');
    }
  }

  Future<WeatherReport> fetchWeather(City city) async {
    final data = await _get(Uri.https('api.open-meteo.com', '/v1/forecast', {
      'latitude': '${city.latitude}',
      'longitude': '${city.longitude}',
      'current':
          'temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,weather_code,wind_speed_10m',
      'daily':
          'weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max',
      'timezone': 'auto',
      'forecast_days': '3',
      'temperature_unit': 'celsius',
      'wind_speed_unit': 'kmh',
      'precipitation_unit': 'mm',
    }));
    try {
      return WeatherReport.fromJson(data);
    } on FormatException {
      throw const WeatherException(
          'Dữ liệu thời tiết không hợp lệ. Vui lòng thử lại.');
    }
  }

  void close() => _client.close();
}
