import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor: Colors.white,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black, fontSize: 24),
      bodyMedium: TextStyle(color: Colors.black, fontSize: 20),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor: Color(0xFF1C1C1E), 
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white, fontSize: 24),
      bodyMedium: TextStyle(color: Colors.white, fontSize: 20),
    ),
    cardColor: Color(0xFF2A2A2D), 
  );
}
