import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class DatabaseRepository {
  static final DatabaseRepository _instance = DatabaseRepository._internal();
  static Database? _database;
  static const String _databaseName = 'timetable.db';

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
    final dir = await getDatabasesPath();
    final path = p.join(dir, fileName);
    if (!await File(path).exists()) {
      await _copyDatabase(fileName);
    }
    return await openDatabase(path);
  }
}
