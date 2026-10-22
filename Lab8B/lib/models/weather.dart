// API models and small, explainable decision rules. No HTTP or widgets here.
double readNumber(dynamic value) {
  if (value is! num || !value.isFinite) {
    throw const FormatException('Expected a finite number.');
  }
  return value.toDouble();
}

int readInt(dynamic value) {
  final number = readNumber(value);
  if (number != number.roundToDouble()) {
    throw const FormatException('Expected an integer.');
  }
  return number.toInt();
}

String readString(dynamic value) {
  if (value is! String || value.trim().isEmpty) {
    throw const FormatException('Expected text.');
  }
  return value;
}

DateTime readTime(dynamic value) {
  final parsed = DateTime.tryParse(readString(value));
  if (parsed == null) throw const FormatException('Invalid timestamp.');
  return parsed;
}

class City {
  final String name;
  final String country;
  final String region;
  final double latitude;
  final double longitude;

  const City(
      {required this.name,
      required this.latitude,
      required this.longitude,
      this.country = '',
      this.region = ''});

  factory City.fromJson(Map<String, dynamic> json) {
    final latitude = readNumber(json['latitude']);
    final longitude = readNumber(json['longitude']);
    if (latitude.abs() > 90 || longitude.abs() > 180) {
      throw const FormatException('Invalid coordinates.');
    }
    return City(
        name: readString(json['name']),
        latitude: latitude,
        longitude: longitude,
        country: json['country'] == null ? '' : readString(json['country']),
        region: json['admin1'] == null ? '' : readString(json['admin1']));
  }

  String get subtitle =>
      [region, country].where((s) => s.isNotEmpty).join(', ');
  bool sameLocation(City other) =>
      latitude == other.latitude && longitude == other.longitude;
}

// Presets specify locations only; their weather always comes from the API.
const presetCities = [
  City(
      name: 'TP. Hồ Chí Minh',
      latitude: 10.8231,
      longitude: 106.6297,
      country: 'Việt Nam'),
  City(
      name: 'Hà Nội',
      latitude: 21.0285,
      longitude: 105.8542,
      country: 'Việt Nam'),
  City(
      name: 'Đà Nẵng',
      latitude: 16.0544,
      longitude: 108.2022,
      country: 'Việt Nam'),
];

class CurrentWeather {
  final DateTime time;
  final double temperature;
  final double feelsLike;
  final double windSpeed;
  final double precipitation;
  final int humidity;
  final int code;

  const CurrentWeather(
      {required this.time,
      required this.temperature,
      required this.feelsLike,
      required this.windSpeed,
      required this.precipitation,
      required this.humidity,
      required this.code});

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    final humidity = readInt(json['relative_humidity_2m']);
    final wind = readNumber(json['wind_speed_10m']);
    final precipitation = readNumber(json['precipitation']);
    if (humidity < 0 || humidity > 100 || wind < 0 || precipitation < 0) {
      throw const FormatException('Out-of-range current weather.');
    }
    return CurrentWeather(
        time: readTime(json['time']),
        temperature: readNumber(json['temperature_2m']),
        feelsLike: readNumber(json['apparent_temperature']),
        windSpeed: wind,
        precipitation: precipitation,
        humidity: humidity,
        code: readInt(json['weather_code']));
  }
}

class ForecastDay {
  final DateTime date;
  final double high;
  final double low;
  final int? rainChance;
  final int code;

  const ForecastDay(
      {required this.date,
      required this.high,
      required this.low,
      required this.rainChance,
      required this.code});

  factory ForecastDay.fromJson(Map<String, dynamic> json) {
    final chance = json['precipitation_probability_max'] == null
        ? null
        : readInt(json['precipitation_probability_max']);
    final high = readNumber(json['temperature_2m_max']);
    final low = readNumber(json['temperature_2m_min']);
    if (high < low || (chance != null && (chance < 0 || chance > 100))) {
      throw const FormatException('Out-of-range forecast.');
    }
    return ForecastDay(
        date: readTime(json['time']),
        high: high,
        low: low,
        rainChance: chance,
        code: readInt(json['weather_code']));
  }
}

class WeatherReport {
  final CurrentWeather current;
  final List<ForecastDay> days;
  final String timezone;

  const WeatherReport(
      {required this.current, required this.days, required this.timezone});

  factory WeatherReport.fromJson(Map<String, dynamic> json) {
    final current = json['current'];
    final daily = json['daily'];
    if (current is! Map<String, dynamic> || daily is! Map<String, dynamic>) {
      throw const FormatException('Missing weather sections.');
    }
    final times = daily['time'];
    if (times is! List) throw const FormatException('Missing forecast dates.');
    const fields = [
      'temperature_2m_max',
      'temperature_2m_min',
      'precipitation_probability_max',
      'weather_code'
    ];
    for (final field in fields) {
      if (daily[field] is! List ||
          (daily[field] as List).length != times.length) {
        throw const FormatException('Forecast arrays have different lengths.');
      }
    }
    return WeatherReport(
      current: CurrentWeather.fromJson(current),
      timezone: readString(json['timezone']),
      days: List.unmodifiable(List.generate(
          times.length,
          (index) => ForecastDay.fromJson({
                'time': times[index],
                for (final field in fields) field: (daily[field] as List)[index]
              }))),
    );
  }
}

String weatherDescription(int code) => switch (code) {
      0 => 'Trời quang',
      1 => 'Ít mây',
      2 => 'Mây rải rác',
      3 => 'Nhiều mây',
      45 || 48 => 'Sương mù',
      51 || 53 || 55 => 'Mưa phùn',
      56 || 57 => 'Mưa phùn đóng băng',
      61 || 63 || 65 => 'Mưa',
      66 || 67 => 'Mưa đóng băng',
      71 || 73 || 75 || 77 => 'Tuyết',
      80 || 81 || 82 => 'Mưa rào',
      85 || 86 => 'Mưa tuyết',
      95 || 96 || 97 || 99 => 'Dông',
      _ => 'Chưa rõ điều kiện (mã $code)',
    };

bool isWet(int code) => const {
      51,
      53,
      55,
      56,
      57,
      61,
      63,
      65,
      66,
      67,
      71,
      73,
      75,
      77,
      80,
      81,
      82,
      85,
      86,
      95,
      96,
      97,
      99
    }.contains(code);
bool isStorm(int code) => const {95, 96, 97, 99}.contains(code);

class WeatherTip {
  final String title;
  final String reason;
  const WeatherTip(this.title, this.reason);
}

class WeatherAdvice {
  final WeatherTip umbrella;
  final WeatherTip clothing;
  final WeatherTip outdoor;
  const WeatherAdvice(this.umbrella, this.clothing, this.outdoor);

  factory WeatherAdvice.forReport(WeatherReport report) {
    final current = report.current;
    final today = report.days.first;
    final chance = today.rainChance;
    final wet = current.precipitation > 0 ||
        isWet(current.code) ||
        isWet(today.code) ||
        (chance != null && chance >= 40);
    final wetReason = current.precipitation > 0
        ? 'Có mưa/tuyết trong khoảng đo hiện tại.'
        : isWet(current.code)
            ? 'Hiện tại: ${weatherDescription(current.code)}.'
            : isWet(today.code)
                ? 'Dự báo hôm nay: ${weatherDescription(today.code)}.'
                : 'Khả năng mưa cao nhất hôm nay từ 40%.';
    final umbrella = wet
        ? WeatherTip('Nên mang ô hoặc áo mưa',
            '$wetReason${chance == null ? '' : ' Xác suất mưa cao nhất: $chance%.'}')
        : chance == null || current.code > 3 || today.code > 3
            ? const WeatherTip('Kiểm tra mưa trước khi đi',
                'Dữ liệu chưa đủ để kết luận khả năng mưa thấp.')
            : WeatherTip('Khả năng mưa thấp',
                'Khả năng mưa cao nhất hôm nay: $chance%.');
    final clothing = current.feelsLike >= 32
        ? WeatherTip('Chọn trang phục thoáng nhẹ',
            'Cảm giác như ${current.feelsLike.round()}°C lúc này.')
        : current.feelsLike < 20
            ? WeatherTip('Mang thêm áo khoác',
                'Cảm giác như ${current.feelsLike.round()}°C lúc này.')
            : const WeatherTip('Trang phục nhẹ, dễ điều chỉnh',
                'Nhiệt độ cảm nhận hiện tại từ 20 đến dưới 32°C.');
    final outdoor = isStorm(current.code) || isStorm(today.code)
        ? const WeatherTip('Ưu tiên hoạt động trong nhà',
            'Dữ liệu hiện tại hoặc dự báo hôm nay có dông.')
        : current.feelsLike >= 35 || today.high >= 35
            ? const WeatherTip('Tránh vận động giữa trưa',
                'Nhiệt độ cảm nhận hoặc mức cao nhất ngày từ 35°C.')
            : current.windSpeed >= 35
                ? const WeatherTip('Chọn nơi kín gió',
                    'Gió hiện tại từ 35 km/h; cân nhắc hoạt động trong nhà.')
                : wet
                    ? const WeatherTip('Lên phương án trong nhà',
                        'Mưa/tuyết có thể ảnh hưởng lịch đi bộ hoặc dã ngoại.')
                    : current.code > 3 || today.code > 3
                        ? const WeatherTip('Kiểm tra điều kiện trước khi đi',
                            'Có sương mù hoặc mã thời tiết chưa được ứng dụng hỗ trợ.')
                        : const WeatherTip('Có thể cân nhắc đi bộ',
                            'Chưa ghi nhận mưa, nóng hoặc gió mạnh theo các ngưỡng của ứng dụng.');
    return WeatherAdvice(umbrella, clothing, outdoor);
  }
}
