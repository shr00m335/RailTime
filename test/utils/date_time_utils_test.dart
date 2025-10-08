import 'package:flutter_test/flutter_test.dart';
import 'package:railtime/utils/date_time_utils.dart';

void main() {
  group('formatToHHmm Tests', () {
    test('test formatToHHmm', () {
      DateTime dt = DateTime(2025, 09, 25, 19, 27);
      String result = DateTimeUtils.formatToHHmm(dt);
      expect(result, '19:27');
    });
  });
}
