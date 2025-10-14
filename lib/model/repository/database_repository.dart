import 'dart:io';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:railtime/model/lat_lon.dart';
import 'package:railtime/model/line_model.dart';
import 'package:railtime/model/station_model.dart';
import 'package:railtime/model/trip_model.dart';
import 'package:railtime/utils/database_utils.dart';
import 'package:railtime/utils/date_time_utils.dart';
import 'package:sqflite/sqflite.dart';

/// A singleton class that handles CRUD operaion of the database
class DatabaseRepository {
  static final DatabaseRepository _instance = DatabaseRepository._internal();
  static Database? _database;
  static const String _databaseName = 'timetable.db';

  // For Testing
  String? _testDbPath;

  /// This functio should not be used except for testing
  void setTestDatabasePath(String path) {
    _testDbPath = path;
    _database = null;
  }

  factory DatabaseRepository() {
    return _instance;
  }

  DatabaseRepository._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase(_databaseName);
    return _database!;
  }

  Future<void> _copyDatabase(String fileName) async {
    final dbDirectory = await getDatabasesPath();
    final path = p.join(dbDirectory, fileName);
    if (!await File(path).exists()) {
      ByteData data = await rootBundle.load('assets/$fileName');
      List<int> bytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );
      await File(path).writeAsBytes(bytes, flush: true);
    }
  }

  Future<Database> _initDatabase(String fileName) async {
    if (_testDbPath != null) {
      return await openDatabase(_testDbPath!);
    }
    final dir = await getDatabasesPath();
    final path = p.join(dir, fileName);
    if (!await File(path).exists()) {
      await _copyDatabase(fileName);
    }
    return await openDatabase(path);
  }

  // Lines
  /// Get all lines of the given [lineIds]
  ///
  /// Return a map in format of {lineId: [LineModel]}
  Future<Map<String, LineModel>> getLinesByIds(List<String> lineIds) async {
    final Database db = await database;

    final List<dynamic> queryResult = await db.query(
      'Lines',
      columns: ['*'],
      where: 'id IN (${DatabaseUtils.generateInParameters(lineIds)})',
      whereArgs: lineIds,
    );

    return {
      for (Map<String, dynamic> dbMap in queryResult)
        dbMap['id']: LineModel.fromDatabaseMap(dbMap),
    };
  }

  /// Get all lines that serve the station with the given [stationId]
  Future<List<LineModel>> getLinesOfStationId(String stationId) async {
    final Database db = await database;

    final List<dynamic> queryResult = await db.rawQuery(
      '''
        SELECT Lines.*
        FROM Lines
        JOIN StationLines ON Lines.id = StationLines.line_id
        WHERE StationLines.station_id = ?
      ''',
      [stationId],
    );

    return queryResult
        .map((dbMap) => LineModel.fromDatabaseMap(dbMap))
        .toList();
  }

  // Stations

  /// Get the station of the given [stationId], null if no station if found
  Future<StationModel?> getStationById(String stationId) async {
    final Database db = await database;

    final List<dynamic> queryResult = await db.query(
      'Stations',
      columns: ['*'],
      where: 'id = ?',
      whereArgs: [stationId],
    );

    if (queryResult.isEmpty) return null;

    final List<LineModel> lines = await getLinesOfStationId(stationId);

    return StationModel.fromDatabaseMap(queryResult.first, lines);
  }

  /// Get all station locations in latitude and longitude
  Future<Map<String, LatLon>> getAllStationsLocation({
    LatLon? center,
    LatLon? delta,
  }) async {
    final Database db = await database;

    List<dynamic> queryResult;

    if (center != null && delta != null) {
      double lat1 = center.latitude - delta.latitude;
      double lat2 = center.latitude + delta.latitude;
      double lon1 = center.longitude - delta.longitude;
      double lon2 = center.longitude + delta.longitude;

      queryResult = await db.query(
        'Stations',
        columns: ['id', 'lat', 'lon'],
        where: '(lat BETWEEN ? AND ?) AND (lon BETWEEN ? AND ?)',
        whereArgs: [
          min(lat1, lat2),
          max(lat1, lat2),
          min(lon1, lon2),
          max(lon1, lon2),
        ],
      );
    } else {
      queryResult = await db.query('Stations', columns: ['id', 'lat', 'lon']);
    }

    return {
      for (Map<String, dynamic> dbMap in queryResult)
        dbMap['id'].toString(): LatLon(
          double.parse(dbMap['lat'].toString()),
          double.parse(dbMap['lon'].toString()),
        ),
    };
  }

  /// Get all stations with the given [stationIds]
  ///
  /// Return in key pair, key: station id and value: station model
  Future<Map<String, StationModel>> getStationsByIds(
    List<String> stationIds,
  ) async {
    final Database db = await database;
    final List<dynamic> queryResult = await db.query(
      'Stations',
      columns: ['*'],
      where: 'id IN (${DatabaseUtils.generateInParameters(stationIds)})',
      whereArgs: stationIds,
    );
    final Map<String, List<LineModel>> lines = {
      for (String stationId in stationIds)
        stationId: await getLinesOfStationId(stationId),
    };

    return {
      for (Map<String, dynamic> dbMap in queryResult)
        dbMap['id'].toString(): StationModel.fromDatabaseMap(
          dbMap,
          lines[dbMap['id'].toString()]!,
        ),
    };
  }

  /// Get all stations related to [hubId]
  ///
  /// Return a list of [StationModel] related to [hubId]
  Future<List<StationModel>> getStationsRelatedToHubId(String hubId) async {
    final Database db = await database;
    final List<dynamic> queryResult = await db.query(
      'Stations',
      columns: ['*'],
      where: 'parent = ?',
      whereArgs: [hubId],
    );

    final List<String> stationIds =
        queryResult.map((x) => x['id'].toString()).toList();
    final Map<String, List<LineModel>> lines = {
      for (String stationId in stationIds)
        stationId: await getLinesOfStationId(stationId),
    };

    return queryResult
        .map(
          (dbMap) => StationModel.fromDatabaseMap(
            dbMap,
            lines[dbMap['id'].toString()] ?? [],
          ),
        )
        .toList();
  }

  /// Get a list of stopping sequence of [stationIds] on [lineId]
  ///
  /// Return a map in the format of {[stationId]: sequence}
  Future<Map<String, int>> getStationsSequencesOnLine(
    String lineId,
    List<String> stationIds,
  ) async {
    if (stationIds.isEmpty) return {};
    final Database db = await database;
    final List<dynamic> queryResult = await db.query(
      'Routes',
      columns: ['station_id', 'sequence'],
      where:
          'line_id = ? AND station_id in (${DatabaseUtils.generateInParameters(stationIds)})',
      whereArgs: [lineId, ...stationIds],
    );
    return {
      for (Map<String, dynamic> dbMap in queryResult)
        dbMap['station_id'].toString(): dbMap['sequence'],
    };
  }

  /// Get the name of [hubId]
  ///
  /// Return the hub's name if one is found, empty string otherwise
  Future<String> getHubNameByHubId(String hubId) async {
    final Database db = await database;
    final List<dynamic> queryResult = await db.query(
      'Hubs',
      columns: ['name'],
      where: 'id = ?',
      whereArgs: [hubId],
    );
    return queryResult.firstOrNull?['name'] ?? '';
  }

  /// Get list of trip ids by that satisfy [lineId], [stationId], and within [timeRange] (in seconds) of [time]
  ///
  /// [timeRange] is the maximum seconds be before the given [time], default is 300 seconds
  /// For example, the [time] is 19:20 and [timeRange] is 300, it will query all arrivals of [lineId] from 19:15 to 19:20
  /// Time after given [time] will not be considered as trains should not arrival before the scheduled time
  ///
  /// Return a list of trip ids that is in the order of closest time to the given [time]
  Future<List<String>> getTripIdsOfLine(
    String lineId,
    String stationId,
    DateTime time, {
    int timeRange = 300,
  }) async {
    final Database db = await database;

    final int targetSeconds = DateTimeUtils.datetimeToSeconds(time);
    final int minSeconds =
        targetSeconds - timeRange > 0
            ? targetSeconds - timeRange
            : 86400 - timeRange + targetSeconds;

    // Convert weekday int to binary format
    // bit 7 represents Monday and bit 0 represents Sunday
    final int weekday = 1 << (7 - time.weekday);

    List<dynamic> queryResult;

    // Query two days if the time range span over two days
    if (minSeconds > targetSeconds) {
      final int previousWeekday = (weekday << 1) >= 128 ? 1 : weekday << 1;
      queryResult = await db.rawQuery(
        '''
          SELECT trip_id, MIN(ABS(? - departure_time), ABS(? + 86400 - departure_time)) AS diff
          FROM Timetables
          WHERE 
            line_id = ? AND 
            stop_id = ? AND
            (
              (service & ? != 0 AND departure_time BETWEEN ? AND ?) OR
              (service & ? != 0 AND departure_time BETWEEN ? AND ?)
            )
          ORDER BY diff ASC
        ''',
        [
          targetSeconds,
          targetSeconds,
          lineId,
          stationId,
          previousWeekday,
          minSeconds,
          86400 + targetSeconds,
          weekday,
          0,
          targetSeconds,
        ],
      );
    } else {
      queryResult = await db.rawQuery(
        '''
          SELECT trip_id, (? - departure_time) AS diff
          FROM Timetables
          WHERE 
            line_id = ? AND 
            stop_id = ? AND
            service & ? != 0 AND 
            departure_time BETWEEN ? AND ?
          ORDER BY diff ASC
        ''',
        [targetSeconds, lineId, stationId, weekday, minSeconds, targetSeconds],
      );
    }

    return queryResult
        .map((dbMap) => dbMap['trip_id']?.toString())
        .whereType<String>()
        .toList();
  }

  /// Get the destination ids of the given list of [tripIds]
  ///
  /// Return a map in the format of {tripId : destination id}
  Future<Map<String, String>> getTripDesinationIdsByIds(
    List<String> tripIds,
  ) async {
    final db = await database;
    final queryResult = await db.query(
      'Timetables',
      columns: ['trip_id', 'stop_id'],
      where:
          'trip_id IN (${DatabaseUtils.generateInParameters(tripIds)}) AND is_last = 1',
      whereArgs: tripIds,
    );
    return {
      for (Map<String, dynamic> dbMap in queryResult)
        dbMap['trip_id']: dbMap['stop_id'],
    };
  }

  /// Get the trip by [tripId]
  ///
  /// Return [TripModel] with [TripArrivalModel] in ascending order of sequences
  Future<List<TripArrivalModel>> getTripById(String tripId) async {
    final Database db = await database;
    final List<dynamic> queryResult = await db.query(
      'Timetables',
      columns: ['*'],
      where: 'trip_id = ?',
      whereArgs: [tripId],
      orderBy: 'stop_sequence',
    );

    if (queryResult.isEmpty) return [];

    final List<String> stationIds =
        queryResult
            .map((dbMap) => dbMap['stop_id']?.toString())
            .whereType<String>()
            .toList();
    final Map<String, StationModel> stations = await getStationsByIds(
      stationIds,
    );
    final List<TripArrivalModel> arrivals =
        queryResult
            .where((dbMap) => stations.keys.contains(dbMap['stop_id']))
            .map(
              (dbMap) => TripArrivalModel.fromDatabaseMap(
                dbMap,
                stations[dbMap['stop_id']]!,
              ),
            )
            .toList();
    return arrivals;
  }
}
