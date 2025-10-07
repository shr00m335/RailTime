import 'dart:io';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:railtime/model/lat_lon.dart';
import 'package:railtime/model/line_model.dart';
import 'package:railtime/model/station_model.dart';
import 'package:railtime/utils/database_utils.dart';
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
}
