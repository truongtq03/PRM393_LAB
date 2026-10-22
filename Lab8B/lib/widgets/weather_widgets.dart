import 'package:flutter/material.dart';
import '../models/weather.dart';

String dayLabel(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
String timeLabel(DateTime date) =>
    '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

IconData weatherIcon(int code) {
  if (isStorm(code)) return Icons.thunderstorm_outlined;
  if (const {71, 73, 75, 77, 85, 86}.contains(code)) return Icons.ac_unit;
  if (isWet(code)) return Icons.umbrella_outlined;
  if (code == 0 || code == 1) return Icons.wb_sunny_outlined;
  if (code == 2 || code == 3) return Icons.cloud_outlined;
  return Icons.waves_outlined;
}

class StatusSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final VoidCallback? onRetry;
  const StatusSection(
      {super.key,
      required this.icon,
      required this.title,
      required this.message,
      this.onRetry});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 28),
        child: Column(children: [
          Icon(icon, size: 40, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 12),
          Text(title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center),
          if (onRetry != null)
            Padding(
                padding: const EdgeInsets.only(top: 12),
                child: FilledButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Thử lại'))),
        ]),
      );
}

class WeatherDashboard extends StatelessWidget {
  final City city;
  final WeatherReport report;
  const WeatherDashboard({super.key, required this.city, required this.report});

  Widget _metric(BuildContext context, String label, String value) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF536275))),
          const SizedBox(height: 3),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      );

  Widget _tip(BuildContext context, IconData icon, WeatherTip tip) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(tip.title,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(tip.reason,
                    style: const TextStyle(color: Color(0xFF536275))),
              ])),
        ]),
      );

  Widget _current(BuildContext context) {
    final current = report.current;
    final today = report.days.first;
    return Card(
      color: const Color(0xFFE5EFFC),
      elevation: 0,
      child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${current.temperature.round()}°C',
                        style: const TextStyle(
                            fontSize: 48, fontWeight: FontWeight.w700)),
                    Text(weatherDescription(current.code),
                        style: Theme.of(context).textTheme.titleMedium),
                  ],
                )),
                Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Icon(weatherIcon(current.code),
                        size: 42,
                        color: Theme.of(context).colorScheme.primary)),
              ]),
              const SizedBox(height: 18),
              Wrap(spacing: 28, runSpacing: 16, children: [
                _metric(
                    context, 'Cảm giác như', '${current.feelsLike.round()}°C'),
                _metric(context, 'Độ ẩm', '${current.humidity}%'),
                _metric(context, 'Gió',
                    '${current.windSpeed.toStringAsFixed(1)} km/h'),
                _metric(
                    context,
                    'Mưa hôm nay',
                    today.rainChance == null
                        ? 'Chưa có dữ liệu'
                        : '${today.rainChance}%'),
              ]),
              const SizedBox(height: 16),
              Text(
                  'Mức thấp / cao hôm nay: ${today.low.round()}° / ${today.high.round()}°C'),
              const SizedBox(height: 8),
              Text(
                  'Dữ liệu lúc ${timeLabel(current.time)}, ${dayLabel(current.time)} • ${report.timezone}',
                  style:
                      const TextStyle(fontSize: 12, color: Color(0xFF536275))),
            ],
          )),
    );
  }

  Widget _advice(BuildContext context) {
    final advice = WeatherAdvice.forReport(report);
    return Card(
      elevation: 0,
      color: Colors.white,
      child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Chuẩn bị cho hôm nay',
                  style: Theme.of(context).textTheme.titleLarge),
              _tip(context, Icons.umbrella_outlined, advice.umbrella),
              _tip(context, Icons.checkroom_outlined, advice.clothing),
              _tip(context, Icons.directions_walk, advice.outdoor),
              const Text(
                  'Gợi ý theo các ngưỡng đơn giản từ dữ liệu hiện tại và dự báo ngày.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF536275))),
            ],
          )),
    );
  }

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(city.name,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          if (city.subtitle.isNotEmpty) Text(city.subtitle),
          const SizedBox(height: 12),
          LayoutBuilder(builder: (context, constraints) {
            if (constraints.maxWidth >= 760) {
              return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _current(context)),
                    const SizedBox(width: 12),
                    Expanded(child: _advice(context)),
                  ]);
            }
            return Column(children: [
              _current(context),
              const SizedBox(height: 12),
              _advice(context)
            ]);
          }),
          const SizedBox(height: 24),
          Text('Dự báo 3 ngày', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          // Builder used inside the page's single scrolling ListView.
          ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: report.days.length,
              itemBuilder: (context, index) {
                final day = report.days[index];
                return Card(
                  elevation: 0,
                  color: Colors.white,
                  child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(children: [
                        Icon(weatherIcon(day.code)),
                        const SizedBox(width: 14),
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Text(
                                  '${dayLabel(day.date)} • ${day.low.round()}° / ${day.high.round()}°C',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600)),
                              Text('${weatherDescription(day.code)} • '
                                  '${day.rainChance == null ? 'Chưa có xác suất mưa' : 'Mưa ${day.rainChance}%'}'),
                            ])),
                      ])),
                );
              }),
        ],
      );
}
