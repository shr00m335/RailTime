import 'package:railtime/model/line_model.dart';
import 'package:railtime/model/station_model.dart';
import 'package:railtime/utils/date_time_utils.dart';

class TripModel {
  final String id;
  final LineModel line;
  final int service;
  final StationModel origin;
  final StationModel destination;
  final List<TripArrivalModel> arrivals;

  const TripModel(
    this.id,
    this.line,
    this.service,
    this.origin,
    this.destination,
    this.arrivals,
  );
}

class TripArrivalModel {
  final StationModel station;
  final int? scheduled;
  final int? actual;
  final String? platform;
  final int sequence;
  final bool isStopping;

  const TripArrivalModel(
    this.station,
    this.scheduled,
    this.actual,
    this.platform,
    this.sequence,
    this.isStopping,
  );

  static TripArrivalModel fromDatabaseMap(
    Map<String, dynamic> dbMap,
    StationModel station,
  ) {
    return TripArrivalModel(
      station,
      dbMap['departure_time'],
      dbMap['departure_time'],
      null,
      dbMap['stop_sequence'],
      true,
    );
  }

  static TripArrivalModel fromApiMap(
    Map<String, dynamic> apiMap,
    StationModel station,
  ) {
    String? platform = apiMap['platformName']?.toString();
    return TripArrivalModel(
      station,
      null,
      apiMap.containsKey('expectedArrival')
          ? DateTimeUtils.datetimeToSeconds(
            DateTime.parse(apiMap['expectedArrival']),
          )
          : null,
      platform?.split(' ').last,
      0,
      true,
    );
  }
}
