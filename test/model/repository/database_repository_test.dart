import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:railtime/model/repository/database_repository.dart';
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
}
