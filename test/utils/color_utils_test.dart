import 'package:flutter/widgets.dart';
import 'package:railtime/utils/color_utils.dart';
import 'package:test/test.dart';

void main() {
  group('uint24ToColor Tests', () {
    test('Convert 16777215 to white (#FFFFFF)', () {
      Color color = ColorUtils.uint24ToColor(16777215);
      expect(color, Color.fromARGB(255, 255, 255, 255));
    });

    test('Convert 0 to black (#000000)', () {
      Color color = ColorUtils.uint24ToColor(0);
      expect(color, Color.fromARGB(255, 0, 0, 0));
    });

    test('Convert 5911205', () {
      Color color = ColorUtils.uint24ToColor(5911205);
      expect(color, Color.fromARGB(255, 90, 50, 165));
    });

    test('Convert 3985685726, should ignore region outside the 24 bits', () {
      Color color = ColorUtils.uint24ToColor(3985685726);
      expect(color, Color.fromARGB(255, 144, 188, 222));
    });
  });
}
