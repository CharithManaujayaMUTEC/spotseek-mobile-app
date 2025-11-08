import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppThemeData {
  final ThemeData light;
  final ThemeData dark;
  const AppThemeData({required this.light, required this.dark});
}

final appThemeProvider = Provider<AppThemeData>((ref) {
  const seed = Colors.deepPurple;
  final light = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: seed),
    useMaterial3: true,
    scaffoldBackgroundColor: Colors.black,
    textTheme: const TextTheme(
      titleLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white70),
    ),
  );
  final dark = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark),
    useMaterial3: true,
    scaffoldBackgroundColor: Colors.black,
  );
  return AppThemeData(light: light, dark: dark);
});
