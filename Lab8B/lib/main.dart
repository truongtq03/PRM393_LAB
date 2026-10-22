import 'package:flutter/material.dart';
import 'screens/weather_screen.dart';
import 'services/weather_service.dart';

void main() => runApp(const WeatherApp());

class WeatherApp extends StatelessWidget {
  // A caller that injects the service is also responsible for closing it.
  final WeatherService? service;
  const WeatherApp({super.key, this.service});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Lab 8B • Weather Companion',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF205DA4)),
          scaffoldBackgroundColor: const Color(0xFFF3F6FB),
          inputDecorationTheme: const InputDecorationTheme(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder()),
        ),
        home: WeatherScreen(service: service),
      );
}
