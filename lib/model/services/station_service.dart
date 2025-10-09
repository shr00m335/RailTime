import 'package:railtime/enums/app_enums.dart';
import 'package:railtime/model/lat_lon.dart';
import 'package:railtime/model/repository/database_repository.dart';
import 'package:railtime/model/station_model.dart';

class StationService {
  /// Get the station by id
  ///
  /// Return [StationModel] if a station is found, null otherwise
  /// If station is related to other station, return a [StationMode] hub instead
  Future<Map<String, StationModel>> getStations(List<String> stationIds) async {
    final Map<String, StationModel> stationEntries = await DatabaseRepository()
        .getStationsByIds(stationIds);

    final Map<String, StationModel> stations = {};

    for (MapEntry<String, StationModel> entry in stationEntries.entries) {
      final station = entry.value;
      if (station.parentId.isEmpty) {
        stations[entry.key] = station;
      } else {
        final String hubName = await DatabaseRepository().getHubNameByHubId(
          station.parentId,
        );
        final List<StationModel> children = await DatabaseRepository()
            .getStationsRelatedToHubId(station.parentId);
        stations[entry.key] = StationModel.createHub(
          station.parentId,
          hubName,
          children,
        );
      }
    }
    return stations;
  }

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
    final StationModel? nearestStation =
        (await getStations([nearestStationId]))[nearestStationId];
    return nearestStation;
  }
}
