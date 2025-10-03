import 'package:railtime/model/line_model.dart';

class StationModel {
  final String id;
  final String name;
  final List<LineModel> lines;
  final double latitude;
  final double longtitude;
  final String parentId;

  StationModel(
    this.id,
    this.name,
    this.lines,
    this.latitude,
    this.longtitude,
    this.parentId,
  );

  /// A function to convert the result query from the database to a [StationModel]
  ///
  /// [dbMap] must be the map returned from the database query
  static StationModel fromDatabaseMap(
    Map<String, dynamic> dbMap,
    List<LineModel> lines,
  ) {
    return StationModel(
      dbMap['id'],
      dbMap['name'],
      lines,
      dbMap['lat'],
      dbMap['lon'],
      dbMap['parent'],
    );
  }
}
