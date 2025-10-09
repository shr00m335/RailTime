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

  group('getStations Tests', () {
    test('test with non-hub station', () async {
      final Map<String, StationModel> station = await service.getStations([
        '940GZZLUEMB',
      ]); // Embankment
      expect(station.length, 1);
      expect(station['940GZZLUEMB']!.name, 'Embankment');
      expect(station['940GZZLUEMB']!.isHub, false);
      expect(station['940GZZLUEMB']!.children.length, 0);
    });
    test('test with 2 non-hub stations', () async {
      final Map<String, StationModel> station = await service.getStations([
        '940GZZLUEMB',
        '940GZZLUKPK',
      ]); // Embankment
      expect(station.length, 2);
      expect(station['940GZZLUEMB']!.name, 'Embankment');
      expect(station['940GZZLUKPK']!.name, 'Kilburn Park');
    });
    test('test with 1 hub and 1 non-hub stations', () async {
      final Map<String, StationModel> station = await service.getStations([
        '940GZZLUPAH',
        '940GZZLUKPK',
      ]); // Embankment
      expect(station.length, 2);
      expect(station['940GZZLUPAH']!.name, 'Paddington');
      expect(station['940GZZLUPAH']!.isHub, true);
      expect(station['940GZZLUKPK']!.name, 'Kilburn Park');
      expect(station['940GZZLUKPK']!.isHub, false);
    });
    test('test with 1 existing and 1 non-existing stations', () async {
      final Map<String, StationModel> station = await service.getStations([
        '940GZZLUPAH1',
        '940GZZLUKPK',
      ]); // Embankment
      expect(station.length, 1);
      expect(station['940GZZLUKPK']!.name, 'Kilburn Park');
      expect(station['940GZZLUKPK']!.isHub, false);
    });

    test('test with hub station', () async {
      Map<String, StationModel> station = await service.getStations([
        '940GZZLUPAH',
      ]); // Paddington
      expect(station.length, 1);
      expect(station['940GZZLUPAH']!.name, 'Paddington');
      expect(station['940GZZLUPAH']!.isHub, true);
      expect(station['940GZZLUPAH']!.lines.length, 5);
      expect(station['940GZZLUPAH']!.children.length, 4);
    });
    test('test with non-existing station', () async {
      Map<String, StationModel> station = await service.getStations([
        '940GZZLUPAH1',
      ]); // Embankment
      expect(station.length, 0);
    });
  });
}
