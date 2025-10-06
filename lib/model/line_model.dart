import 'package:flutter/widgets.dart';
import 'package:railtime/utils/color_utils.dart';

class LineModel {
  final String id;
  final String name;
  final String mode;
  final Color color;
  final String direction0;
  final String direction1;
  final String destinations0;
  final String desintations1;

  const LineModel(
    this.id,
    this.name,
    this.mode,
    this.color,
    this.direction0,
    this.direction1,
    this.destinations0,
    this.desintations1,
  );

  /// A function to convert the result query from the database to a [LineModel]
  ///
  /// [dbMap] must be the map returned from the database query
  static LineModel fromDatabaseMap(Map<String, dynamic> dbMap) {
    return LineModel(
      dbMap['id'],
      dbMap['name'],
      dbMap['mode'],
      ColorUtils.uint24ToColor(dbMap['color']),
      dbMap['direction_0'],
      dbMap['direction_1'],
      dbMap['destinations_0'],
      dbMap['destinations_1'],
    );
  }
}
