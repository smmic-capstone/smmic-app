import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:smmic/utils/logs.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:smmic/models/device_data_models.dart';

class DatabaseHelper {
  // dependencies
  final Logs _logs = Logs(tag: 'DatabaseHelper');

  static final DatabaseHelper _instance = DatabaseHelper._();
  DatabaseHelper._();
  static DatabaseHelper get instance => _instance;

  Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _getDatabase();
    return _database!;
  }
  
  static Future<Database> _getDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, _databaseName);
    return openDatabase(
      path,
      version: _version,
    );
  }
  
  static const int _version = 1;
  static const String _databaseName = "smmic_data.db";

  static const String _sinkDataTable =
      "CREATE TABLE IF NOT EXISTS SinkData ("
          "hash_id TEXT PRIMARY KEY, "
          "device_id TEXT NOT NULL, "
          "timestamp DATETIME, "
          "connected_clients INT, "
          "total_clients INT, "
          "sub_count INT, "
          "bytes_sent INT, "
          "bytes_received INT, "
          "messages_sent INT, "
          "messages_received INT, "
          "battery_level DECIMAL(10, 7) "
          ")";
  
  static const String _sensorDataTable =
      "CREATE TABLE IF NOT EXISTS SMSensorReadings  ("
          "hash_id TEXT PRIMARY KEY NOT NULL, "
          "device_id TEXT NOT NULL, "
          "timestamp DATETIME, "
          "soil_moisture DECIMAL(10,7), "
          "temperature DECIMAL(10,7), "
          "humidity DECIMAL(10,7), "
          "battery_level DECIMAL(10,7)"
          ")";
  
  Future<void> initLocalStorage() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, _databaseName);
    Database db = await openDatabase(
        path,
        version: _version,
        onOpen: (db) async {
          await db.execute(
              _sinkDataTable
          );
          await db.execute(
              _sensorDataTable
          );
        },
    );
    db.close();
    _logs.info2(message: 'local storage initialized');
  }

  static Future<void> addReadings(List<SensorNodeSnapshot> readings) async {
    final db = await _getDatabase();
    List<int> results = [];
    for (SensorNodeSnapshot snapshot in readings) {
      Map<String, dynamic> jsonSnapshot = snapshot.toJson();
      jsonSnapshot['hash_id'] = sha256.convert(
        utf8.encode('${snapshot.deviceID}${snapshot.timestamp}')
      ).toString();
      List<Map<String, dynamic>> checkExists = await db.query(
          "SMSensorReadings",
        where: 'hash_id = ?',
        whereArgs: [jsonSnapshot['hash_id']],
        limit: 1
      );
      if (checkExists.isNotEmpty) {
        continue;
      }
      results.add(
          await db.insert(
              "SMSensorReadings",
              jsonSnapshot,
              conflictAlgorithm: ConflictAlgorithm.replace
          )
      );
    }
    Logs(tag: 'db.addReadings()').info2(message: results.toString());
  }

  static Future<SensorNodeSnapshot?> getSeReading(String deviceID) async {
    final db = await _getDatabase();
    final List<Map<String, dynamic>> queryResult = await db.query("SMSensorReadings",
        where: 'device_id = ?',
        whereArgs: [deviceID],
        orderBy: 'timestamp DESC',
        limit: 1
    );
    if (queryResult.isEmpty) {
      return null;
    }
    try {
      final snapshot = SensorNodeSnapshot.fromJSON(queryResult.first);
      return snapshot;
    } catch (e) {
      return null;
    }
  }

  static Future<void> readingsLimit(String deviceID) async {
    final db = await _getDatabase();

    final countResult = await db.rawQuery(
      "SELECT COUNT(*) AS count FROM SMSensorReadings WHERE device_id = ?",
      [deviceID],
    );

    final count = Sqflite.firstIntValue(countResult) ?? 0;
    const limit = 100;

    if (count > limit) {
      final excess = count - limit;

      await db.delete("SMSensorReadings",
          where:
              "device_id = ? AND timestamp IN (SELECT timestamp from SMSensorReadings WHERE device_id = ? ORDER BY timestamp ASC LIMIT ?)",
          whereArgs: [deviceID, deviceID, excess]);
    }
  }
  
  static int maxChartLength = 10;
  static Future<List<SensorNodeSnapshot>?>chartReadings(String deviceID) async {
    final db = await _getDatabase();

    final List<Map<String,dynamic>> queryResult = await db.query(
      "SMSensorReadings",
      where: 'device_id = ?',
      whereArgs: [deviceID],
      orderBy: 'timestamp DESC',
      limit: maxChartLength,
    );

    final readings = queryResult.map(
            (data) => SensorNodeSnapshot.fromJSON(data)
    ).toList().reversed.toList();

    return readings;
  }
}
