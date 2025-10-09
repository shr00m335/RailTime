import 'package:railtime/model/lat_lon.dart';
import 'package:railtime/model/line_model.dart';

class StationModel {
  final bool isHub;
  final String id;
  final String name;
  final List<LineModel> _lines;
  final LatLon location;
  final String parentId;
  final List<StationModel> children;

  StationModel(
    this.id,
    this.name,
    this._lines,
    this.location,
    this.parentId,
    this.isHub,
    this.children,
  );

  List<LineModel> get lines {
    if (isHub) {
      final Set<String> lineIds = {};
      return children.expand((station) => station.lines).where((line) {
        if (lineIds.contains(line.id)) {
          return false;
        } else {
          lineIds.add(line.id);
          return true;
        }
      }).toList();
    } else {
      return _lines;
    }
  }

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
      false,
      [],
    );
  }

  /// A function to create a hub with [id], [name] and [children]
  ///
  /// [lines] with be empty
  /// [location] with be one of the children location
  static StationModel createHub(
    String id,
    String name,
    List<StationModel> children,
  ) {
    return StationModel(
      id,
      name,
      [],
      children.first.location,
      '',
      true,
      children,
    );
  }
}
