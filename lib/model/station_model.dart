import 'package:railtime/model/lat_lon.dart';
import 'package:railtime/model/line_model.dart';

class StationModel {
  final String id;
  final String name;
  final List<LineModel> lines;
  final LatLon location;
  final String parentId;

  StationModel(this.id, this.name, this.lines, this.location, this.parentId);

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
      LatLon(dbMap['lat'], dbMap['lon']),
      dbMap['parent'],
    );
  }
}
