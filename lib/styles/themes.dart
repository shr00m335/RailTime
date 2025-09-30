import 'package:flutter/material.dart';
import 'package:railtime/styles/colors.dart';

TextStyle londonTubeFont(TextStyle style) {
  return style.copyWith(fontFamily: 'LondonTube');
}

ThemeData get lightTheme {
  return ThemeData(
    primaryColor: AppColors.blue,
    textTheme: TextTheme(
      headlineLarge: londonTubeFont(
        TextStyle(color: Colors.white, fontSize: 24.0),
      ),
      headlineMedium: londonTubeFont(
        TextStyle(color: Colors.white, fontSize: 20.0),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.blue,
      unselectedLabelStyle: TextStyle(fontFamily: 'LondonTube'),
      selectedLabelStyle: TextStyle(fontFamily: 'LondonTube'),
      unselectedItemColor: Color.fromARGB(255, 179, 179, 179),
      selectedItemColor: Colors.white,
    ),
  );
}
