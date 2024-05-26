import 'package:flutter/material.dart';

final ThemeData myTheme = ThemeData(
  // Define the primary color for your app
  primaryColor: Colors.teal,

  // Define the text theme for the app
  textTheme: TextTheme(
    displayLarge: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
    displayMedium: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
    displaySmall: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
    bodyLarge: TextStyle(fontSize: 16.0),
    bodyMedium: TextStyle(fontSize: 14.0),
  ),

  // Define the elevated button theme
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.white,
      backgroundColor: Colors.teal, // Button text color
      elevation: 4.0, // Button shadow
    ),
  ),

  // Define the input decoration theme for text fields
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
    ),
  ),

  // Define the scaffold background color
  scaffoldBackgroundColor: Colors.white,

  // Define the alert dialog theme
  dialogTheme: DialogTheme(
    backgroundColor: Colors.white,
  ),

  // Define the card theme
  cardTheme: CardTheme(
    elevation: 4.0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.0),
    ),
  ),
  colorScheme: ColorScheme.fromSwatch(
    primarySwatch: Colors.teal,
    accentColor: Colors.deepOrange,
    brightness: Brightness.light,
  ).copyWith(secondary: Colors.deepOrange),
);
