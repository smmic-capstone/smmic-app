import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:smmic/utils/logs.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:smmic/models/device_data_models.dart';

class DatabaseHelper {
  // dependencies
  final Logs _logs = Logs(tag: 'DatabaseHelper');

  static const int _version = 1;
  static const String dbName = "Readings.db";

  static Future<Database> _getDB() async {
    return openDatabase(join(await getDatabasesPath(), dbName),
        onCreate: (db, version) async {
      await db.execute(
          "CREATE TABLE IF NOT EXISTS SMSensorReadings ("
              "hash_id TEXT PRIMARY KEY NOT NULL, "
              "device_id TEXT NOT NULL, "
              "timestamp DATETIME, "
              "soil_moisture DECIMAL(10,7), "
              "temperature DECIMAL(10,7), "
              "humidity DECIMAL(10,7), "
              "battery_level DECIMAL(10,7)"
              ")"
      );
      ///TODO: Add more tables if necessary
    }, version: _version);
  }

  static Future<void> addReadings(List<SensorNodeSnapshot> readings) async {
    final db = await _getDB();
    List<int> results = [];
    for (SensorNodeSnapshot snapshot in readings) {
      Map<String, dynamic> jsonSnapshot = snapshot.toJson();
      jsonSnapshot['hash_id'] = sha256.convert(
        utf8.encode('${snapshot.deviceID}${snapshot.timestamp}')
      ).toString();
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
    final db = await _getDB();
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
    final db = await _getDB();

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
  
  
  static Future<List<SensorNodeSnapshot>?>chartReadings(String deviceID) async {
    final db = await _getDB();

    final List<Map<String,dynamic>> queryResult = await db.query(
      "SMSensorReadings",
      where: 'device_id = ?',
      whereArgs: [deviceID],
      orderBy: 'timestamp DESC',
      limit: 6,
    );

    final readings = queryResult.map(
            (data) => SensorNodeSnapshot.fromJSON(data)
    ).toList().reversed.toList();

    return readings;
  }
}
