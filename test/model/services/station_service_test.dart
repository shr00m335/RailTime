import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:railtime/model/lat_lon.dart';
import 'package:railtime/model/repository/database_repository.dart';
import 'package:railtime/model/services/station_service.dart';
import 'package:railtime/model/station_model.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late StationService service;
  late DatabaseRepository repository;

  setUp(() {
    service = StationService();
    // Setup Database
    repository = DatabaseRepository();
    databaseFactory = databaseFactoryFfi;
    final testDbPath = p.join(Directory.current.path, 'assets', 'timetable.db');
    repository.setTestDatabasePath(testDbPath);
  });

  tearDown(() async {
    final db = await repository.database;
    await db.close();
  });
  group('getNearestStation Tests', () {
    sqfliteFfiInit();

    test('test getNearestStation', () async {
      LatLon targetLatLon = LatLon(
        51.529060,
        -0.132613,
      ); // A point outside Euston station
      StationModel? nearestStation = await service.getNearestStation(
        targetLatLon,
      );
      expect(nearestStation != null, true); // Should return a station
      expect(nearestStation!.id, 'HUBEUS'); // Should be Euston station
      expect(nearestStation.isHub, true); // Should be a hub
      expect(nearestStation.children.length, 2); // Should have 2 children
    });

    test('test getNearestStation out of range', () async {
      LatLon targetLatLon = LatLon(
        52.844007,
        -3.260173,
      ); // A point outside London
      StationModel? nearestStation = await service.getNearestStation(
        targetLatLon,
      );
      expect(nearestStation, null); // Should not return any station
    });
  });

  group('getStation Tests', () {
    test('test with non-hub station', () async {
      StationModel? station = await service.getStation(
        '940GZZLUEMB',
      ); // Embankment
      expect(station!.name, 'Embankment');
      expect(station.isHub, false);
      expect(station.children.length, 0);
    });

    test('test with hub station', () async {
      StationModel? station = await service.getStation(
        '940GZZLUPAH',
      ); // Embankment
      expect(station!.name, 'Paddington');
      expect(station.isHub, true);
      expect(station.lines.length, 0);
      expect(station.children.length, 4);
    });
    test('test with non-existing station', () async {
      StationModel? station = await service.getStation(
        '940GZZLUPAH1',
      ); // Embankment
      expect(station, null);
    });
  });
}
