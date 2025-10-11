import 'package:railtime/constants/line_constants.dart';
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

  @override
  bool operator ==(Object other) {
    return other is ArrivalModel &&
        headcode == other.headcode &&
        line.id == other.line.id &&
        platform == other.platform &&
        estimatedArrival.millisecondsSinceEpoch ==
            other.estimatedArrival.millisecondsSinceEpoch &&
        (destination?.id ?? destinationText) ==
            (other.destination?.id ?? destinationText);
  }

  @override
  int get hashCode => Object.hash(
    headcode,
    line.id,
    platform,
    direction,
    destination?.id ?? destinationText,
    estimatedArrival.millisecondsSinceEpoch,
  );

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
    int? direction,
  ) {
    String platform = dbMap['platformName'].toString();

    return ArrivalModel(
      dbMap['vehicleId'].toString(),
      line,
      platform.substring(platform.length - 1),
      direction ??
          (dbMap.keys.contains('direction')
              ? (LineConstants.directions[line.id]?[dbMap['direction']] ?? -1)
              : -1),
      destination,
      dbMap['towards']?.toString() ?? '',
      DateTime.parse(dbMap['expectedArrival'].toString()),
      DateTime.parse(dbMap['expectedArrival'].toString()),
    );
  }
}
