import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData dark() {
    const seed = Color(0xFF0B1F36);
    const surface = Color(0xFF050912);
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seed,
        brightness: Brightness.dark,
        surface: surface,
        primary: const Color(0xFFFF4B91),
        secondary: const Color(0xFF5FFBF1),
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: Colors.transparent,
      textTheme: base.textTheme.apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      sliderTheme: base.sliderTheme.copyWith(
        thumbColor: Colors.white,
        activeTrackColor: Colors.white,
        inactiveTrackColor: Colors.white.withValues(alpha: .3),
      ),
      chipTheme: base.chipTheme.copyWith(
        selectedColor: Colors.white.withValues(alpha: .2),
        backgroundColor: Colors.white.withValues(alpha: .1),
        labelStyle: const TextStyle(color: Colors.white),
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: Colors.white,
        textColor: Colors.white,
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) =>
                states.contains(WidgetState.selected)
                    ? Colors.white.withValues(alpha: .2)
                    : Colors.white.withValues(alpha: .05),
          ),
          foregroundColor: const WidgetStatePropertyAll(Colors.white),
          side: WidgetStatePropertyAll(
            BorderSide(color: Colors.white.withValues(alpha: .3)),
          ),
        ),
      ),
    );
  }
}
