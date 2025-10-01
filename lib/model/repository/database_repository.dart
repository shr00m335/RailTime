import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:railtime/model/lat_lon.dart';
import 'package:railtime/model/line_model.dart';
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

  /// Get all station locations in latitude and longtitude
  Future<Map<String, LatLon>> getAllStationsLocation() async {
    final Database db = await database;

    final List<dynamic> queryResult = await db.query(
      'Stations',
      columns: ['id', 'lat', 'lon'],
    );

    return {
      for (Map<String, dynamic> dbMap in queryResult)
        dbMap['id'].toString(): LatLon(
          double.parse(dbMap['lat'].toString()),
          double.parse(dbMap['lon'].toString()),
        ),
    };
  }
}
