import 'package:railtime/enums/app_enums.dart';
import 'package:railtime/model/lat_lon.dart';
import 'package:railtime/model/repository/database_repository.dart';
import 'package:railtime/model/station_model.dart';

class StationService {
  /// Get the nearest station to a given [location] within [maxDistance]
  ///
  /// [maxDistance] in km or miles
  ///
  /// Return [StationModel] if a station is found within [maxDistance] or null if non is found
  Future<StationModel?> getNearestStation(
    LatLon location, {
    double maxDistance = 2,
    DistanceUnit unit = DistanceUnit.metric,
  }) async {
    final LatLon deltaLatlon = location.getBoundingBoxDelta(
      maxDistance,
      unit: unit,
    );
    final Map<String, LatLon> stationLocations = await DatabaseRepository()
        .getAllStationsLocation(center: location, delta: deltaLatlon);
    if (stationLocations.isEmpty) {
      return null;
    }
    // Get the station id with the distance closest to the location
    final String nearestStationId =
        stationLocations.entries
            .reduce(
              (a, b) => location.closerTo(a.value, b.value) == a.value ? a : b,
            )
            .key;
    // Get station from station id
    final StationModel? nearestStation = await DatabaseRepository()
        .getStationById(nearestStationId);
    return nearestStation;
  }
}
