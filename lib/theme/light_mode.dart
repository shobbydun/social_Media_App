import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    primary: Colors.teal.shade500, // Primary color
    onPrimary: Colors.white, // Text color on primary
    secondary: Colors.orange.shade400, // Secondary color
    onSecondary: Colors.white, // Text color on secondary
    background: Colors.white, // Background color
    onBackground: Colors.black87, // Text color on background
    surface: Colors.grey.shade100, // Surface color
    onSurface: Colors.black87, // Text color on surface
  ),
  textTheme: ThemeData.light().textTheme.apply(
    bodyColor: Colors.black87, // Body text color
    displayColor: Colors.black87, // Display text color
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.teal.shade600, // App bar background
    foregroundColor: Colors.white, // App bar text color
  ),
);
