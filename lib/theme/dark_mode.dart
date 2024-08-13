import 'package:flutter/material.dart';

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    primary: Colors.deepPurple.shade800, // Primary color
    onPrimary: Colors.white, // Text color on primary
    secondary: Color.fromARGB(255, 36, 7, 222), // Secondary color
    onSecondary: Colors.white, // Text color on secondary
    background: Colors.black87, // Background color
    onBackground: Colors.white, // Text color on background
    surface: Colors.grey.shade800, // Surface color
    onSurface: Colors.white, // Text color on surface
  ),
  textTheme: ThemeData.dark().textTheme.apply(
    bodyColor: Colors.white, // Body text color
    displayColor: Colors.white, // Display text color
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.deepPurple.shade900, // App bar background
    foregroundColor: Colors.white, // App bar text color
  ),
);
