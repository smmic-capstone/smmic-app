import 'package:smmic/utils/logs.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:smmic/models/device_data_models.dart';

class DatabaseHelper{
  static const int _version = 1;
  static const String dbName = "Readings.db";

  static Future<Database> _getDB() async {
    return openDatabase(join(await getDatabasesPath(),dbName),
      onCreate: (db, version) async {
        await db.execute(
          "CREATE TABLE SMSensorReadings(device_id TEXT NOT NULL, timestamp DATETIME, soil_moisture DECIMAL(10,7), temperature DECIMAL(10,7), humidity DECIMAL(10,7), battery_level DECIMAL(10,7))"
        );
        ///TODO: Add more tables if necessary
      }, version: _version
    );
  }

  static Future<int> addReadings(SensorNodeSnapshot readings) async {
    print("Adding Mapped Data from Stream to SQFLITE: $readings");
    final db = await _getDB();
    print("Added Mapped Data from Stream to SQFLITE");
    return await db.insert("SMSensorReadings", readings.toJson(),
    conflictAlgorithm: ConflictAlgorithm.replace);
  }


  static Future<SensorNodeSnapshot?> getAllReadings(String deviceID) async {
    print('Readings for deviceID: $deviceID');
    final db = await _getDB();
    final List<Map<String,dynamic>> maps = await db.query("SMSensorReadings",
        where: 'device_id = ?',
        whereArgs: [deviceID],
        orderBy: 'timestamp DESC',
        limit: 1
    );

    print("Raw Data from SQLITe: $maps");

    if(maps.isEmpty){
      print("maps is empty");
      return null;
    }
    try {
      final snapshot = SensorNodeSnapshot.fromJSON(maps.first);
      print("Mapped SensorNodeSnapshot: $snapshot");
      return snapshot;
    } catch (e) {
      print("Error mapping data: $e");
      return null;
    }

  }
}