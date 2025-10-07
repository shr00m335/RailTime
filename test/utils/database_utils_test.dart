import 'package:railtime/utils/database_utils.dart';
import 'package:test/test.dart';

void main() {
  group('generateInParameters Tests', () {
    test('generateInParameters with 0 parameters', () {
      String result = DatabaseUtils.generateInParameters([]);
      expect('', result);
    });
    test('generateInParameters with 3 parameters', () {
      String result = DatabaseUtils.generateInParameters([1, 2, 3]);
      expect('?,?,?', result);
    });
  });
}
