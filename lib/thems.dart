import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
  fontFamily: 'Lateef',
  brightness: Brightness.light,
  // scaffoldBackgroundColor: Colors.white,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    foregroundColor: Colors.black,
    elevation: 0,
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Colors.white,
    selectedItemColor: Colors.deepOrange,
    unselectedItemColor: Colors.grey,
  ),
  textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.black)),
  iconTheme: const IconThemeData(color: Colors.black),
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: Colors.black,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.black,
    foregroundColor: Colors.white,
    elevation: 0,
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Colors.black,
    selectedItemColor: Colors.deepOrange,
    unselectedItemColor: Colors.grey,
  ),
  textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.white)),
  iconTheme: const IconThemeData(color: Colors.white),
  fontFamily: 'sffamily',
);
