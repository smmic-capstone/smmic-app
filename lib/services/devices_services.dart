import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:smmic/constants/api.dart';
import 'package:smmic/providers/auth_provider.dart';
import 'package:smmic/utils/api.dart';
import 'package:smmic/utils/auth_utils.dart';
import 'package:smmic/utils/logs.dart';
import '../utils/shared_prefs.dart';

class DevicesServices {
  // dependencies
  final ApiRoutes _apiRoutes = ApiRoutes();
  final ApiRequest _apiRequest = ApiRequest();
  final AuthUtils _authUtils = AuthUtils();
  final AuthProvider _authProvider = AuthProvider();
  final SharedPrefsUtils _sharedPrefsUtils = SharedPrefsUtils();
  final Logs _logs = Logs(tag: 'DevicesServices()');

  /// Retrieves all devices registered to the user, requires the user id
  Future<List<Map<String, dynamic>>?> getDevices({required String userID, required String token}) async {
    List<Map<String, dynamic>> sinkNodesParsed = [];

    final Map<String, dynamic> data = await _apiRequest.get(route: _apiRoutes.getDevices, headers: {'Authorization': 'Bearer $token', 'UID': userID});

    if (data.containsKey('error') || data.isEmpty || data['data'] == null) {
      _logs.error(message: 'data received from ApiRequest().get() contains error or invalid value: ${data.values}');
    } else {
      List<dynamic> sinkNodesUnparsed = data['data'];

      // parse devices
      for (var sinkUnparsed in sinkNodesUnparsed) {
        List<dynamic> sensorNodesUnparsed = sinkUnparsed['sensor_nodes'];
        List<Map<String, dynamic>> sensorNodesParsed = [];
        for (var sensorUnparsed in sensorNodesUnparsed) {
          sensorNodesParsed.add({
            'device_id': sensorUnparsed['device_id'],
            'name': sensorUnparsed['name'],
            'latitude': sensorUnparsed['latitude'],
            'longitude': sensorUnparsed['longitude'],
            'interval': sensorUnparsed['interval'],
            'soil_threshold': sensorUnparsed['soil_threshold'],
            'humidity_threshold': sensorUnparsed['humidity_threshold'],
            'temperature_threshold': sensorUnparsed['temperature_threshold']
          });
        }
        sinkNodesParsed.add({
          'device_id': sinkUnparsed['device_id'],
          'name': sinkUnparsed['name'],
          'latitude': sinkUnparsed['latitude'],
          'longitude': sinkUnparsed['longitude'],
          'sensor_nodes': sensorNodesParsed
        });
      }
    }

    // type: List<Map<String, dynamic>>
    return sinkNodesParsed.isNotEmpty ? sinkNodesParsed : null;
  }

  Future<Map<String, List<Map<String, dynamic>>>> getSinkBatchSnapshots(List<String> sinkIds) async {
    Map<String, List<Map<String, dynamic>>> finalMap = {};
    for (String sinkId in sinkIds) {
      Map<String, dynamic> res = await _apiRequest.get(route: _apiRoutes.getSinkReadings, headers: {'Sink': sinkId});
      if (res.containsKey('error')) {
        _logs.warning(
            message: 'request for $sinkId returned with error ->'
                'code: ${res['status_code']}, body: ${res['body']}');
      } else {
        List<Map<String, dynamic>> castedList = [];
        for (dynamic item in res['data']) {
          castedList.add(item as Map<String, dynamic>);
        }
        finalMap[sinkId] = castedList;
      }
    }
    return finalMap;
  }

  Future<Map<String, List<Map<String, dynamic>>>> getSensorBatchSnapshots(List<String> sensorIds) async {
    Map<String, List<Map<String, dynamic>>> finalMap = {};
    for (String sensorId in sensorIds) {
      Map<String, dynamic> res = await _apiRequest.get(route: _apiRoutes.getSensorReadings, headers: {'Sensor': sensorId});
      if (res.containsKey('error')) {
        _logs.warning(
            message: 'request for $sensorId returned with error ->'
                'code: ${res['status_code']}, body: ${res['body']}');
      } else {
        List<Map<String, dynamic>> castedList = [];
        for (dynamic item in res['data']) {
          castedList.add(item as Map<String, dynamic>);
          finalMap[sensorId] = castedList;
        }
      }
    }
    return finalMap;
  }

  Future<Map<String, dynamic>?> updateSKDeviceName({required String token, required String deviceID, required Map<String, dynamic> sinkName}) async {
    String? accessToken;
    TokenStatus accessStatus = await _authUtils.verifyToken(token: token);

    if (accessStatus != TokenStatus.valid) {
      Map<String, dynamic> refresh = await _sharedPrefsUtils.getTokens(refresh: true);
      accessToken = await _authUtils.refreshAccessToken(refresh: refresh['refresh']);
      await _authProvider.setAccess(access: accessToken!);
    }

    final Map<String, dynamic> data =
        await _apiRequest.patch(route: _apiRoutes.updateSKName, headers: {'Authorization': 'Bearer $token', 'Sink': deviceID}, body: sinkName);

    // TODO: HANDLE ERROR SCENARIO
    if (data.containsKey('error')) {
      return data;
    }

    return data;
  }

  Future<Map<String, dynamic>?> updateSNDeviceName(
      {required String token, required String deviceID, required Map<String, dynamic> sensorName, required String sinkNodeID}) async {
    String? accessToken;
    TokenStatus accessStatus = await _authUtils.verifyToken(token: token);

    if (accessStatus != TokenStatus.valid) {
      Map<String, dynamic> refresh = await _sharedPrefsUtils.getTokens(refresh: true);
      accessToken = await _authUtils.refreshAccessToken(refresh: refresh['refresh']);
      await _authProvider.setAccess(access: accessToken!);
    }

    debugPrint("snDeviceNameBody: ${jsonEncode(sensorName).toString()}");


    final Map<String, dynamic> data = await _apiRequest.patch(
        route: _apiRoutes.updateSNName, headers: {
          'Authorization': 'Bearer $token', 'Sensor': deviceID, 'Content-Type': 'application/json'}, body: jsonEncode(sensorName));
    debugPrint("updateSNDeviceName:  ${data.toString()}");
    // TODO: HANDLE ERROR SCENARIO
    if (data.containsKey('error')) {
      return data;
    }

    return data;
  }
}
