import 'dart:math' as math;

import 'package:railtime/enums/app_enums.dart';

class LatLon {
  final double latitude;
  final double longitude;

  const LatLon(this.latitude, this.longitude);

  @override
  operator ==(other) =>
      other is LatLon &&
      latitude == other.latitude &&
      longitude == other.longitude;

  @override
  int get hashCode => Object.hash(latitude, longitude);

  /// Calculate the distance between this LatLon and the target LatLon
  double distanceTo(LatLon target, {DistanceUnit unit = DistanceUnit.metric}) {
    double R = unit == DistanceUnit.imperial ? 3959 : 6371; // default km

    // Haversin Formula
    double lat1 = latitude * math.pi / 180;
    double lat2 = target.latitude * math.pi / 180;
    double lon1 = longitude * math.pi / 180;
    double lon2 = target.longitude * math.pi / 180;

    double dLon = lon2 - lon1;
    double dLat = lat2 - lat1;

    double a =
        (math.pow(math.sin(dLat / 2), 2) +
            math.cos(lat1) * math.cos(lat2) * math.pow(math.sin(dLon / 2), 2));
    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return R * c;
  }

  /// Given two [LatLon], [latlon1] and [latlon2], return the [LatLon] that is close to the the current [LatLon]
  ///
  /// Return the closer [LatLon],
  /// if two distances are the same, return [latlon1]
  ///
  /// This function uses squared Euclidean distance
  LatLon closerTo(LatLon latlon1, LatLon latlon2) {
    double dLatLon1 =
        (math.pow(latlon1.latitude - latitude, 2) as double) +
        (math.pow(latlon1.longitude - longitude, 2) as double);
    double dLatLon2 =
        (math.pow(latlon2.latitude - latitude, 2) as double) +
        (math.pow(latlon2.longitude - longitude, 2) as double);
    return dLatLon1 <= dLatLon2 ? latlon1 : latlon2;
  }

  /// Get a rough approximation of a bound box that has a [distance] away from the current [LatLon]
  ///
  /// current [LatLon] as the center
  ///
  /// [distance] is the distance from the center to the edges of the bounding box
  /// [unit] is either metric (km) of imperial (miles)
  ///
  /// Return a LatLon that stores the delta to the edges of bounding box
  LatLon getBoundingBoxDelta(
    double distance, {
    DistanceUnit unit = DistanceUnit.metric,
  }) {
    double distancePerLat = unit == DistanceUnit.imperial ? 69.054 : 111.32;
    double distancePerLon = distancePerLat * math.cos(latitude * math.pi / 180);

    return LatLon(distance / distancePerLat, distance / distancePerLon);
  }
}
