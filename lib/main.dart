import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const WeatherPinApp());
}

class WeatherPinApp extends StatelessWidget {
  const WeatherPinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather Pin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
