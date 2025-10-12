import 'package:flutter/cupertino.dart';
import 'package:railtime/model/arrival_model.dart';
import 'package:railtime/model/lat_lon.dart';
import 'package:railtime/model/repository/database_repository.dart';
import 'package:railtime/model/services/location_service.dart';
import 'package:railtime/model/services/station_service.dart';
import 'package:railtime/model/services/tfl_api_service.dart';
import 'package:railtime/model/station_model.dart';

class LiveInfoViewModel with ChangeNotifier {
  final DatabaseRepository _databaseRepository = DatabaseRepository();
  final StationService _stationService = StationService();
  final LocationService _locationService = LocationService();
  final TflApiService _tflApiService = TflApiService();

  LatLon? _currentLocation;
  StationModel? _nearestStation;
  Map<String, List<ArrivalModel>>? _arrivals;

  StationModel? get nearestStation {
    return _nearestStation;
  }

  LatLon? get currentLocation {
    return _currentLocation;
  }

  Map<String, List<ArrivalModel>>? get arrivals {
    return _arrivals;
  }

  Future<void> getNearestStation() async {
    _currentLocation = await _locationService.getCurrentLocation();
    if (_currentLocation == null) {
      // Set station to King's Cross St. Pancras if failed to get location
      _nearestStation = await _databaseRepository.getStationById('940GZZLUKSX');
    } else {
      _nearestStation = await _stationService.getNearestStation(
        _currentLocation!,
      );
    }
    notifyListeners();
    await getArrivals();
  }

  Future<void> getArrivals() async {
    if (_nearestStation == null) return;
    _arrivals = await _tflApiService.getArrivals(_nearestStation!);
    notifyListeners();
  }
}
