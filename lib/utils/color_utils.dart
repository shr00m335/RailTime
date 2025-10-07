import 'package:flutter/material.dart';

class ColorUtils {
  static Color uint24ToColor(int uint24) {
    final int red = uint24 >> 16;
    final int green = uint24 >> 8 & 0xFF;
    final int blue = uint24 & 0xFF;

    return Color.fromARGB(255, red, green, blue);
  }
}
