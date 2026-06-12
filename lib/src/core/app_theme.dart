import 'package:flutter/material.dart';

const forgeBlack = Color(0xFF050607);
const forgePanel = Color(0xFF111417);
const forgePanelAlt = Color(0xFF191D22);
const forgeSteel = Color(0xFF9BA3AF);
const forgeText = Color(0xFFF4F7FB);
const forgeElectric = Color(0xFF20E3B2);
const forgeHot = Color(0xFFFF4D4D);
const forgeGold = Color(0xFFFFC857);

ThemeData buildIronForgeTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: forgeElectric,
    brightness: Brightness.dark,
    surface: forgePanel,
    primary: forgeElectric,
    secondary: forgeGold,
    error: forgeHot,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: forgeBlack,
    colorScheme: scheme,
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      backgroundColor: forgeBlack,
      foregroundColor: forgeText,
      centerTitle: false,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: forgePanel,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: forgePanelAlt,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: forgeElectric,
        foregroundColor: forgeBlack,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(fontWeight: FontWeight.w800),
      ),
    ),
  );
}
