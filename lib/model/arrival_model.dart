import 'package:railtime/model/line_model.dart';
import 'package:railtime/model/station_model.dart';

class ArrivalModel {
  final String headcode;
  final LineModel line;
  final String platform;
  final int direction;
  final StationModel? destination;
  final String destinationText;
  final DateTime scheduledArrival;
  final DateTime estimatedArrival;

  const ArrivalModel(
    this.headcode,
    this.line,
    this.platform,
    this.direction,
    this.destination,
    this.destinationText,
    this.scheduledArrival,
    this.estimatedArrival,
  );

  static ArrivalModel fromDatabaseMap(
    Map<String, dynamic> dbMap,
    LineModel line,
    StationModel? destination,
    int direction,
  ) {
    String platform = dbMap['platformName'].toString();

    return ArrivalModel(
      dbMap['vehicleId'].toString(),
      line,
      platform.substring(platform.length - 1),
      direction,
      destination,
      dbMap['towards']?.toString() ?? '',
      DateTime.parse(dbMap['expectedArrival'].toString()),
      DateTime.parse(dbMap['expectedArrival'].toString()),
    );
  }
}
