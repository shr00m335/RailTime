import 'package:flutter_test/flutter_test.dart';
import 'package:railtime/enums/app_enums.dart';
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

  group('closeTo Tests', () {
    test('latlon1 closer', () {
      LatLon baseLatLon = LatLon(
        51.532528,
        -0.139252,
      ); // Location near Mornington Crescent
      LatLon latlon1 = LatLon(51.534679, -0.138789); // Mornington Crescent
      LatLon latlon2 = LatLon(51.528344, -0.1323); // Euston
      LatLon result = baseLatLon.closerTo(latlon1, latlon2);
      expect(result, latlon1);
    });

    test('latlon2 closer', () {
      LatLon baseLatLon = LatLon(51.530389, -0.134214); // Location near Euston
      LatLon latlon1 = LatLon(51.534679, -0.138789); // Mornington Crescent
      LatLon latlon2 = LatLon(51.528344, -0.1323); // Euston
      LatLon result = baseLatLon.closerTo(latlon1, latlon2);
      expect(result, latlon2);
    });

    test('latlon1 and latlon2 have same distance', () {
      LatLon baseLatLon = LatLon(51.530389, -0.134214);
      LatLon latlon1 = LatLon(51.534679, -0.138789);
      LatLon latlon2 = LatLon(51.534679, 0.138789);
      LatLon result = baseLatLon.closerTo(latlon1, latlon2);
      expect(
        result,
        latlon1,
      ); // Should return latlon1 if two distances are the same
    });
  });

  group('getBoundingBoxDelta Tests', () {
    test('test getBoundingBoxDelta in km', () {
      LatLon baseLatLon = LatLon(51.530389, -0.134214);
      LatLon targetLatLon = LatLon(
        51.536926,
        -0.142465,
      ); // A point within the 2km distance

      LatLon delta = baseLatLon.getBoundingBoxDelta(2);
      expect(
        targetLatLon.latitude - baseLatLon.latitude < delta.latitude,
        true,
      );
      expect(
        targetLatLon.longtitude - baseLatLon.longtitude < delta.longtitude,
        true,
      );
    });

    test('test getBoundingBoxDelta in miles', () {
      LatLon baseLatLon = LatLon(51.530389, -0.134214);
      LatLon targetLatLon = LatLon(
        51.544695,
        -0.154358,
      ); // A point within the 2 miles distance

      LatLon delta = baseLatLon.getBoundingBoxDelta(
        2,
        unit: DistanceUnit.imperial,
      );
      expect(
        targetLatLon.latitude - baseLatLon.latitude < delta.latitude,
        true,
      );
      expect(
        targetLatLon.longtitude - baseLatLon.longtitude < delta.longtitude,
        true,
      );
    });
  });
}
