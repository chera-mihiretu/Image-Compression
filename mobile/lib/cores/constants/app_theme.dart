import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(centerTitle: true),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        shape: StadiumBorder(),
      ),
      cardTheme: CardThemeData(
        clipBehavior: Clip.antiAlias,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
