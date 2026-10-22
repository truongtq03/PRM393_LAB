Map<String, dynamic> weatherJson(
        {int code = 1,
        int dailyCode = 2,
        double temperature = 26,
        double feelsLike = 27,
        double high = 29,
        double wind = 8,
        int? rainChance = 10}) =>
    {
      'timezone': 'Asia/Ho_Chi_Minh',
      'current': {
        'time': '2026-10-22T14:00',
        'temperature_2m': temperature,
        'apparent_temperature': feelsLike,
        'relative_humidity_2m': 65,
        'wind_speed_10m': wind,
        'precipitation': 0,
        'weather_code': code
      },
      'daily': {
        'time': ['2026-10-22', '2026-10-23', '2026-10-24'],
        'temperature_2m_max': [high, high, high],
        'temperature_2m_min': [22, 22, 22],
        'weather_code': [dailyCode, dailyCode, dailyCode],
        'precipitation_probability_max': [rainChance, rainChance, rainChance]
      },
    };

const cityJson = {
  'name': 'London',
  'latitude': 51.5,
  'longitude': -0.12,
  'country': 'United Kingdom',
  'admin1': 'England'
};
