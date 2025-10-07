import 'package:flutter/cupertino.dart';
import 'package:railtime/model/lat_lon.dart';
import 'package:railtime/model/repository/database_repository.dart';
import 'package:railtime/model/services/location_service.dart';
import 'package:railtime/model/services/station_service.dart';
import 'package:railtime/model/station_model.dart';

class LiveInfoViewModel with ChangeNotifier {
  final DatabaseRepository _databaseRepository = DatabaseRepository();
  final StationService _stationService = StationService();
  final LocationService _locationService = LocationService();

  LatLon? _currentLocation;
  StationModel? _nearestStation;

  StationModel? get nearestStation {
    return _nearestStation;
  }

  LatLon? get currentLocation {
    return _currentLocation;
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
  }
}
