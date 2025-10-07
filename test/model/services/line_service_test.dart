import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:railtime/model/repository/database_repository.dart';
import 'package:railtime/model/services/line_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late LineService service;
  late DatabaseRepository repository;

  setUp(() {
    service = LineService();
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
  group('getDirectionsByDestinations Tests', () {
    test('Test with non valid line id', () async {
      Map<String, int> results = await service.getDirectionsByDestinations(
        'abc',
        '940GZZLUERB',
        ['940GZZLUEAC', '940GZZLUHAW'],
      );
      expect(results, {});
    });
    test('Test with bakerloo', () async {
      Map<String, int> results = await service.getDirectionsByDestinations(
        'bakerloo',
        '940GZZLUERB',
        ['940GZZLUEAC', '940GZZLUHAW', '910GWATFDHS'],
      );
      expect(results.length, 2);
      expect(results['940GZZLUEAC'], 1);
      expect(results['940GZZLUHAW'], 0);
    });
    test('Test station not on line', () async {
      Map<String, int> results = await service.getDirectionsByDestinations(
        'bakerloo',
        '910GWATFDHS',
        ['940GZZLUEAC', '940GZZLUHAW', '910GWATFDHS'],
      );
      expect(results, {});
    });
  });
}
