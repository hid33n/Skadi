import 'package:flutter/material.dart';

class AppTheme {
  // Nueva paleta de colores: Negro, Amarillo y Blanco
  static const _primaryColor = Color(0xFFFFD700); // Amarillo dorado
  static const _secondaryColor = Color(0xFFFFEB3B); // Amarillo más claro
  static const _accentColor = Color(0xFFFFC107); // Amarillo ámbar
  static const _errorColor = Color(0xFFE57373);
  static const _successColor = Color(0xFF81C784);
  static const _warningColor = Color(0xFFFFB74D);
  
  // Colores base
  static const _blackColor = Color(0xFF1A1A1A); // Negro suave
  static const _darkGrayColor = Color(0xFF2D2D2D); // Gris oscuro
  static const _lightGrayColor = Color(0xFFF5F5F5); // Gris claro
  static const _whiteColor = Color(0xFFFFFFFF); // Blanco puro

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: _primaryColor,
      onPrimary: _blackColor,
      secondary: _secondaryColor,
      onSecondary: _blackColor,
      tertiary: _accentColor,
      onTertiary: _blackColor,
      error: _errorColor,
      onError: _whiteColor,
      background: _whiteColor,
      onBackground: _blackColor,
      surface: _whiteColor,
      onSurface: _blackColor,
      surfaceContainerHighest: _lightGrayColor,
      onSurfaceVariant: Color(0xFF666666),
    ),
    scaffoldBackgroundColor: _whiteColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: _blackColor,
      foregroundColor: _primaryColor,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: _primaryColor),
      titleTextStyle: TextStyle(
        color: _primaryColor,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    ),
    cardTheme: CardTheme(
      color: _whiteColor,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: _primaryColor.withOpacity(0.1), width: 1),
      ),
      shadowColor: _blackColor.withOpacity(0.15),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _lightGrayColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _primaryColor.withOpacity(0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _primaryColor.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _errorColor, width: 2),
      ),
      labelStyle: const TextStyle(color: Color(0xFF666666)),
      floatingLabelStyle: const TextStyle(color: _primaryColor, fontWeight: FontWeight.bold),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryColor,
        foregroundColor: _blackColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _primaryColor,
        textStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: _primaryColor,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _primaryColor,
      foregroundColor: _blackColor,
      elevation: 4,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: _blackColor,
      indicatorColor: _primaryColor.withOpacity(0.2),
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(color: _primaryColor, fontWeight: FontWeight.w500),
      ),
      iconTheme: WidgetStateProperty.all(
        const IconThemeData(color: _primaryColor),
      ),
    ),
    navigationRailTheme: const NavigationRailThemeData(
      backgroundColor: _blackColor,
      selectedIconTheme: IconThemeData(color: _primaryColor),
      unselectedIconTheme: IconThemeData(color: Color(0xFF999999)),
      selectedLabelTextStyle: TextStyle(color: _primaryColor, fontWeight: FontWeight.bold),
      unselectedLabelTextStyle: TextStyle(color: Color(0xFF999999)),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: _primaryColor.withOpacity(0.1),
      labelStyle: const TextStyle(color: _blackColor, fontWeight: FontWeight.w500),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: _primaryColor.withOpacity(0.3)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: _blackColor,
      contentTextStyle: const TextStyle(color: _primaryColor),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      behavior: SnackBarBehavior.floating,
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFFE0E0E0),
      thickness: 1,
      space: 1,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: _primaryColor,
      onPrimary: _blackColor,
      secondary: _secondaryColor,
      onSecondary: _blackColor,
      tertiary: _accentColor,
      onTertiary: _blackColor,
      error: _errorColor,
      onError: _whiteColor,
      background: _blackColor,
      surface: _darkGrayColor,
      onSurface: _whiteColor,
    ),
    scaffoldBackgroundColor: _blackColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: _darkGrayColor,
      foregroundColor: _primaryColor,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: _primaryColor),
      titleTextStyle: TextStyle(
        color: _primaryColor,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    ),
    cardTheme: CardTheme(
      color: _darkGrayColor,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: _primaryColor.withOpacity(0.2), width: 1),
      ),
      shadowColor: Colors.black.withOpacity(0.3),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF3A3A3A),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _primaryColor.withOpacity(0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _primaryColor.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _errorColor, width: 2),
      ),
      labelStyle: const TextStyle(color: Color(0xFFCCCCCC)),
      floatingLabelStyle: const TextStyle(color: _primaryColor, fontWeight: FontWeight.bold),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryColor,
        foregroundColor: _blackColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _primaryColor,
        textStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: _primaryColor,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _primaryColor,
      foregroundColor: _blackColor,
      elevation: 4,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: _darkGrayColor,
      indicatorColor: _primaryColor.withOpacity(0.2),
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(color: _primaryColor, fontWeight: FontWeight.w500),
      ),
      iconTheme: WidgetStateProperty.all(
        const IconThemeData(color: _primaryColor),
      ),
    ),
    navigationRailTheme: const NavigationRailThemeData(
      backgroundColor: _darkGrayColor,
      selectedIconTheme: IconThemeData(color: _primaryColor),
      unselectedIconTheme: IconThemeData(color: Color(0xFF999999)),
      selectedLabelTextStyle: TextStyle(color: _primaryColor, fontWeight: FontWeight.bold),
      unselectedLabelTextStyle: TextStyle(color: Color(0xFF999999)),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: _primaryColor.withOpacity(0.1),
      labelStyle: const TextStyle(color: _whiteColor, fontWeight: FontWeight.w500),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: _primaryColor.withOpacity(0.3)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: _darkGrayColor,
      contentTextStyle: const TextStyle(color: _primaryColor),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      behavior: SnackBarBehavior.floating,
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFF424242),
      thickness: 1,
      space: 1,
    ),
  );
} 