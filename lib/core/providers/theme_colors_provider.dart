import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'database_provider.dart';

@immutable
class ThemeColors {
  final Color primary;
  final Color secondary;
  const ThemeColors({required this.primary, required this.secondary});

  static const ThemeColors defaults = ThemeColors(
    primary: Color(0xFF1A237E),
    secondary: Color(0xFF3949AB),
  );
}

Color _parseHex(String? raw, Color fallback) {
  if (raw == null || raw.isEmpty) return fallback;
  try {
    final cleaned = raw.replaceFirst('#', '');
    final value = int.parse(cleaned, radix: 16);
    return Color(value);
  } catch (_) {
    return fallback;
  }
}

String colorToHex(Color c) {
  final argb = c.toARGB32();
  return '#${argb.toRadixString(16).padLeft(8, '0').toUpperCase()}';
}

final themeColorsProvider = StreamProvider<ThemeColors>((ref) {
  final db = ref.watch(databaseProvider);
  return db.select(db.configuracion).watch().map((rows) {
    final map = {for (final r in rows) r.clave: r.valor};
    return ThemeColors(
      primary: _parseHex(map['color_primary'], ThemeColors.defaults.primary),
      secondary:
          _parseHex(map['color_secondary'], ThemeColors.defaults.secondary),
    );
  });
});
