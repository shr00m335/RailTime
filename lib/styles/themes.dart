import 'package:flutter/material.dart';
import 'package:railtime/styles/colors.dart';

TextStyle londonTubeFont(TextStyle style) {
  return style.copyWith(fontFamily: 'LondonTube');
}

ThemeData get lightTheme {
  return ThemeData(
    fontFamily: 'LondonTube',
    primaryColor: AppColors.blue,
    scaffoldBackgroundColor: Color(0xFFDEDEDE),
    indicatorColor: Colors.white,
    cardColor: Colors.white,
    disabledColor: Color.fromARGB(255, 179, 179, 179),
    textTheme: TextTheme(
      headlineLarge: londonTubeFont(
        TextStyle(color: Colors.white, fontSize: 24.0),
      ),
      headlineMedium: londonTubeFont(
        TextStyle(color: Colors.white, fontSize: 20.0),
      ),
      bodyLarge: TextStyle(color: Colors.black, fontSize: 24.0),
      bodyMedium: TextStyle(color: Colors.black, fontSize: 20.0),
      labelSmall: TextStyle(color: Color(0xFF888888), fontSize: 14.0),
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
