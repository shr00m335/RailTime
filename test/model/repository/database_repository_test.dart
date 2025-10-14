import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:railtime/model/lat_lon.dart';
import 'package:railtime/model/line_model.dart';
import 'package:railtime/model/repository/database_repository.dart';
import 'package:railtime/model/station_model.dart';
import 'package:railtime/model/trip_model.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  late DatabaseRepository repository;

  setUp(() async {
    databaseFactory = databaseFactoryFfi;
    repository = DatabaseRepository();
    final testDbPath = p.join(Directory.current.path, 'assets', 'timetable.db');
    repository.setTestDatabasePath(testDbPath);
  });

  tearDown(() async {
    final db = await repository.database;
    await db.close();
  });

  group('getLinesOfStationId Tests', () {
    test('fetch station that does not exist', () async {
      final lines = await repository.getLinesOfStationId('1234');
      expect(0, lines.length); // No line should be returned
    });

    test('fetch station with only 1 line', () async {
      final lines = await repository.getLinesOfStationId('940GZZLUERB');
      expect(1, lines.length); // Only one line is returned
      // Check whether bakerloo line is returned
      expect('bakerloo', lines.first.id);
    });

    test('fetch station with only 5 line', () async {
      final lines = await repository.getLinesOfStationId('940GZZLUBST');
      expect(5, lines.length); // 5 lines should be returned
      // Check whether all lines are returned
      expect('bakerloo', lines.first.id);
      expect('circle', lines[1].id);
      expect('hammersmith-city', lines[2].id);
      expect('jubilee', lines[3].id);
      expect('metropolitan', lines[4].id);
    });
  });

  group('getAllStationsLocation Tests', () {
    test('fetch all station locations', () async {
      final locations = await repository.getAllStationsLocation();
      expect(575, locations.length); // Expect all stations (575)
      expect(LatLon(51.522883, -0.15713), locations['940GZZLUBST']);
    });

    test('fetch all station locations within bounding box', () async {
      final locations = await repository.getAllStationsLocation(
        center: LatLon(51.522883, -0.15713),
        delta: LatLon(0.0001, 0.0001),
      );
      expect(1, locations.length); // Expect only 1 station
      expect(LatLon(51.522883, -0.15713), locations['940GZZLUBST']);
    });
  });

  group('getStationsByIds Tests', () {
    test('Test with empty list of ids', () async {
      final Map<String, StationModel> stations = await repository
          .getStationsByIds([]);
      expect(stations, {});
    });
    test('Test with 1 id', () async {
      final Map<String, StationModel> stations = await repository
          .getStationsByIds(['940GZZLUMVL']);
      expect(stations.length, 1);
      expect(stations['940GZZLUMVL']!.name, 'Maida Vale');
    });
    test('Test with 3 ids', () async {
      final Map<String, StationModel> stations = await repository
          .getStationsByIds(['940GZZLUMVL', '940GZZLUSGP', '940GZZLUQPS']);
      expect(stations.length, 3);
      expect(stations['940GZZLUMVL']!.name, 'Maida Vale');
      expect(stations['940GZZLUSGP']!.name, 'Stonebridge Park');
      expect(stations['940GZZLUQPS']!.name, 'Queen\'s Park');
    });
  });

  group('getStationSequenceOnLine Tests', () {
    test('Test with empty station list', () async {
      final Map<String, int> sequences = await repository
          .getStationsSequencesOnLine('bakerloo', []);
      expect(sequences, {});
    });
    test('Test with non-existing line id', () async {
      final Map<String, int> sequences = await repository
          .getStationsSequencesOnLine('test line', ['940GZZLUMVL']);
      expect(sequences, {});
    });
    test('Test with non-existing stations', () async {
      final Map<String, int> sequences = await repository
          .getStationsSequencesOnLine('bakerloo', ['123']);
      expect(sequences, {});
    });
    test('Test with Bakerloo', () async {
      final Map<String, int> sequences = await repository
          .getStationsSequencesOnLine('bakerloo', [
            '940GZZLUKEN',
            '940GZZLUMVL',
            '910GWATFDHS',
          ]);
      expect(sequences.length, 2);
      expect(sequences['940GZZLUKEN'], 24);
      expect(sequences['940GZZLUMVL'], 14);
    });
  });

  group('getStationsRelatedToHubId Tests', () {
    test('Get Paddington stations', () async {
      final List<StationModel> stations = await repository
          .getStationsRelatedToHubId('HUBPAD');
      expect(stations.length, 4);
      expect(stations[0].id, '940GZZLUPAC');
      expect(stations[1].id, '940GZZLUPAH');
      expect(stations[2].id, '910GPADTLL');
      expect(stations[3].id, '910GPADTON');
    });

    test('Non existing hub id', () async {
      final List<StationModel> stations = await repository
          .getStationsRelatedToHubId('HUBPAD1');
      expect(stations.length, 0);
    });
  });

  group('getHubNameByHubId Tests', () {
    test('Test with normal case', () async {
      final String name = await repository.getHubNameByHubId('HUBPAD');
      expect(name, 'Paddington');
    });
    test('Test if hub id not exists', () async {
      final String name = await repository.getHubNameByHubId('HUBPAD1');
      expect(name, '');
    });
  });

  group('getTripId Tests', () {
    test('Test with getting trip id exactly on time', () async {
      DateTime targetDateTime = DateTime(2025, 10, 12, 17, 31); // Sunday, 17:31
      String lineId = 'district';
      String stationId = '940GZZLUECT';
      String destinationId = '940GZZLUUPM';
      String? tripId = await repository.getTripId(
        lineId,
        stationId,
        destinationId,
        targetDateTime,
        0,
      );
      expect(tripId, 'dis-1320');
    });
    test('Test with getting trip id with 3 mins delay', () async {
      DateTime targetDateTime = DateTime(
        2025,
        10,
        8,
        9,
        37,
      ); // Wednesday, 17:31
      String lineId = 'liberty';
      String stationId = '910GROMFORD';
      String destinationId = '910GROMFORD';
      String? tripId = await repository.getTripId(
        lineId,
        stationId,
        destinationId,
        targetDateTime,
        300,
      ); // Test with 5 mins time range
      expect(tripId, 'lib-63');
    });
    test(
      'Test with getting trip id with 3 mins delay into the next day',
      () async {
        DateTime targetDateTime = DateTime(
          2025,
          10,
          8,
          0,
          1,
        ); // Wednesday, 00:01, Expected, Tuesday, 23:59
        String lineId = 'mildmay';
        String stationId = '910GHGHI';
        String destinationId = '910GWLSDJHL';
        String? tripId = await repository.getTripId(
          lineId,
          stationId,
          destinationId,
          targetDateTime,
          300,
        ); // Test with 5 mins time range
        expect(tripId, 'mild-91');
      },
    );
    test('Test with getting trip id outside time range', () async {
      DateTime targetDateTime = DateTime(
        2025,
        10,
        11,
        23,
        4,
      ); // Saturday, 23:04, Expected, 23:05
      String lineId = 'bakerloo';
      String stationId = '940GZZLURGP';
      String destinationId = '940GZZLUQPS';
      String? tripId = await repository.getTripId(
        lineId,
        stationId,
        destinationId,
        targetDateTime,
        0,
      ); // Test with 5 mins time range
      expect(tripId, null);
    });
  });

  group('getLinesByIds Tests', () {
    test('Test with 1 line id', () async {
      String lineId = 'bakerloo';
      Map<String, LineModel> result = await repository.getLinesByIds([lineId]);
      expect(result.length, 1);
      expect(result['bakerloo']?.name, 'Bakerloo');
    });

    test('Test with 2 line id', () async {
      Map<String, LineModel> result = await repository.getLinesByIds([
        'bakerloo',
        'elizabeth',
      ]);
      expect(result.length, 2);
      expect(result['bakerloo']?.name, 'Bakerloo');
      expect(result['elizabeth']?.name, 'Elizabeth line');
    });

    test('Test with 1 non-existing id', () async {
      Map<String, LineModel> result = await repository.getLinesByIds([
        'bakerloo1',
      ]);
      expect(result.length, 0);
    });

    test('Test with 1 existing and 1 non-existing ids', () async {
      Map<String, LineModel> result = await repository.getLinesByIds([
        'bakerloo1',
        'elizabeth',
      ]);
      expect(result.length, 1);
      expect(result['elizabeth']?.name, 'Elizabeth line');
    });
  });

  group('getTripById Tests', () {
    test('Test with a valid id', () async {
      List<TripArrivalModel> arrivals = await repository.getTripById('elz-20');
      expect(arrivals.length, 22);
      expect(arrivals[5].station.id, '910GLIVSTLL');
      expect(arrivals[5].scheduled, 22800);
      expect(arrivals[5].actual, 22800);
      expect(arrivals[5].platform, null);
      expect(arrivals[5].sequence, 6);
    });

    test('Test with an invalid id', () async {
      List<TripArrivalModel> trip = await repository.getTripById('elz-2012');
      expect(trip, []);
    });
  });
}
