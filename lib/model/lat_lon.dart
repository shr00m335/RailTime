import 'dart:math' as math;

import 'package:railtime/enums/app_enums.dart';

class LatLon {
  final double latitude;
  final double longtitude;

  const LatLon(this.latitude, this.longtitude);

  @override
  operator ==(other) =>
      other is LatLon &&
      latitude == other.latitude &&
      longtitude == other.longtitude;

  @override
  int get hashCode => Object.hash(latitude, longtitude);

  /// Calculate the distance between this LatLon and the target LatLon
  double distanceTo(LatLon target, {DistanceUnit unit = DistanceUnit.metric}) {
    double R = unit == DistanceUnit.imperial ? 3959 : 6371; // default km

    // Haversin Formula
    double lat1 = latitude * math.pi / 180;
    double lat2 = target.latitude * math.pi / 180;
    double lon1 = longtitude * math.pi / 180;
    double lon2 = target.longtitude * math.pi / 180;

    double dLon = lon2 - lon1;
    double dLat = lat2 - lat1;

    double a =
        (math.pow(math.sin(dLat / 2), 2) +
            math.cos(lat1) * math.cos(lat2) * math.pow(math.sin(dLon / 2), 2));
    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return R * c;
  }
}
