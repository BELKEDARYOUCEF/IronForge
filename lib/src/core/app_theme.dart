import 'package:flutter/material.dart';

class IFColors {
  static const black = Color(0xFF050505);
  static const black2 = Color(0xFF090909);
  static const panel = Color(0xFF101010);
  static const panel2 = Color(0xFF151515);
  static const panel3 = Color(0xFF1B1B1B);
  static const border = Color(0xFF2A2A2A);
  static const borderSoft = Color(0xFF202020);
  static const red = Color(0xFFE52B2B);
  static const redDark = Color(0xFF9F1717);
  static const redGlow = Color(0xFFFF3B30);
  static const orange = Color(0xFFFF6A00);
  static const gold = Color(0xFFFFC857);
  static const green = Color(0xFF2ED573);
  static const blue = Color(0xFF3B82F6);
  static const text = Color(0xFFF4F4F5);
  static const textMuted = Color(0xFFA1A1AA);
  static const textFaint = Color(0xFF71717A);
}

const forgeBlack = IFColors.black;
const forgePanel = IFColors.panel;
const forgePanelAlt = IFColors.panel2;
const forgeSteel = IFColors.textMuted;
const forgeText = IFColors.text;
const forgeElectric = IFColors.red;
const forgeHot = IFColors.redGlow;
const forgeGold = IFColors.gold;

ThemeData buildIronForgeTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: IFColors.red,
    brightness: Brightness.dark,
    primary: IFColors.red,
    secondary: IFColors.gold,
    surface: IFColors.panel,
    error: IFColors.redGlow,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: IFColors.black,
    colorScheme: scheme,
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      backgroundColor: IFColors.black,
      foregroundColor: IFColors.text,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.2,
        color: IFColors.text,
      ),
    ),
    cardTheme: CardThemeData(
      color: IFColors.panel,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: IFColors.borderSoft),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: IFColors.panel2,
      labelStyle: const TextStyle(color: IFColors.textMuted),
      hintStyle: const TextStyle(color: IFColors.textFaint),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: IFColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: IFColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: IFColors.red),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: IFColors.red,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(52),
        elevation: 0,
        shadowColor: IFColors.redGlow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle:
            const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.6),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: IFColors.text,
        side: const BorderSide(color: IFColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    dividerTheme:
        const DividerThemeData(color: IFColors.borderSoft, thickness: 1),
    dialogTheme: DialogThemeData(
      backgroundColor: IFColors.panel,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: IFColors.borderSoft),
      ),
    ),
    listTileTheme: const ListTileThemeData(
      iconColor: IFColors.textMuted,
      textColor: IFColors.text,
      subtitleTextStyle: TextStyle(color: IFColors.textMuted),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: IFColors.panel2,
      contentTextStyle:
          const TextStyle(color: IFColors.text, fontWeight: FontWeight.w700),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}
