import 'package:flutter_test/flutter_test.dart';
import 'package:railtime/model/lat_lon.dart';

void main() {
  group('distanceTo Tests', () {
    test('distanceTo in km', () {
      double distance = LatLon(
        51.5007,
        0.1246,
      ).distanceTo(LatLon(40.6892, 74.0445));
      expect(double.parse(distance.toStringAsFixed(1)), 5574.8);
    });
  });
}
