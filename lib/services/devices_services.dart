library devices_services;

import 'package:smmic/constants/api.dart';
import 'package:smmic/models/device_data_models.dart';
import 'package:smmic/providers/auth_provider.dart';
import 'package:smmic/utils/api.dart';
import 'package:smmic/utils/auth_utils.dart';
import 'package:smmic/utils/logs.dart';

import '../utils/shared_prefs.dart';

part 'devices/sensor_data.dart';
part 'devices/sink_data.dart';

class DevicesServices {
  final _SensorNodeDataServices _sensorNodeDataServices =
      _SensorNodeDataServices();
  final _SinkNodeDataServices _sinkNodeDataServices = _SinkNodeDataServices();

  // dependencies
  final ApiRoutes _apiRoutes = ApiRoutes();
  final ApiRequest _apiRequest = ApiRequest();
  final AuthUtils _authUtils = AuthUtils();
  final AuthProvider _authProvider = AuthProvider();
  final SharedPrefsUtils _sharedPrefsUtils = SharedPrefsUtils();
  final Logs _logs = Logs(tag: 'DevicesServices()');

  /// Retrieves all devices registered to the user, requires the user id
  Future<List<Map<String, dynamic>>> getDevices(
      {required String userID, required String token}) async {
    String? accessToken;
    TokenStatus accessStatus = await _authUtils.verifyToken(token: token);

    if (accessStatus != TokenStatus.valid) {
      Map<String, dynamic> refresh =
          await _sharedPrefsUtils.getTokens(refresh: true);
      accessToken =
          await _authUtils.refreshAccessToken(refresh: refresh['refresh']);
      await _authProvider.setAccess(access: accessToken!);
    }

    final Map<String, dynamic> data = await _apiRequest.get(
        route: _apiRoutes.getDevices,
        headers: {'Authorization': 'Bearer $token', 'UID': userID});

    if (data.containsKey('error') || data.isEmpty || data['data'] == null) {
      _logs.error(
          message:
              'data received from ApiRequest().get() contains error or invalid value: ${data.values}');
      throw Exception('unhandled error on DevicesServices().getDevices()');
    }

    _logs.warning(message: data['data'].toString());

    List<dynamic> sinkNodesUnparsed = data['data'];

    List<Map<String, dynamic>> sinkNodesParsed = [];

    // parse devices
    for (int i = 0; i < sinkNodesUnparsed.length; i++) {
      List<dynamic> sensorNodesUnparsed = sinkNodesUnparsed[i]['sensor_nodes'];
      List<Map<String, dynamic>> sensorNodesParsed = [];
      for (int x = 0; x < sensorNodesUnparsed.length; x++) {
        sensorNodesParsed.add({
          'SNID': sensorNodesUnparsed[x]['SNID'],
          'SensorNode_Name': sensorNodesUnparsed[x]['SensorNode_Name']
        });
      }
      sinkNodesParsed.add({
        'SKID': sinkNodesUnparsed[i]['SKID'],
        'SK_Name': sinkNodesUnparsed[i]['SK_Name'],
        'sensor_nodes': sensorNodesParsed
      });
    }

    // type: List<Map<String, dynamic>>
    return sinkNodesParsed;
  }

  /// Returns sensor node snapshot data (`deviceID`, `timestamp`, `soilMoisture`, `temperature`, `humidity`, `batteryLevel`)
  SensorNodeSnapshot getSensorSnapshot({required String id}) {
    return _sensorNodeDataServices.getSnapshot(id);
  }

  /// Returns sink node snapshot data (`deviceID`, `batteryLevel`)
  // SinkNodeSnapshot getSinkSnapshot({required String id}){
  //   return _sinkNodeDataServices.getSnapshot(id);
  // }

  List<SensorNodeSnapshot> getSensorTimeSeries({required String id}) {
    return _sensorNodeDataServices.getTimeSeries(id);
  }

  Future<Map<String, dynamic>?> updateSKDeviceName(
      {required String token,
      required String deviceID,
      required Map<String, dynamic> sinkName}) async {
    String? accessToken;
    TokenStatus accessStatus = await _authUtils.verifyToken(token: token);

    if (accessStatus != TokenStatus.valid) {
      Map<String, dynamic> refresh =
          await _sharedPrefsUtils.getTokens(refresh: true);
      accessToken =
          await _authUtils.refreshAccessToken(refresh: refresh['refresh']);
      await _authProvider.setAccess(access: accessToken!);
    }

    final Map<String, dynamic> data = await _apiRequest.patch(
        route: _apiRoutes.updateSKName,
        headers: {'Authorization': 'Bearer $token', 'Sink': deviceID},
        body: sinkName);

    // TODO: HANDLE ERROR SCENARIO
    if (data.containsKey('error')) {
      return data;
    }

    return data;
  }

  Future<Map<String, dynamic>?> updateSNDeviceName(
      {required String token,
      required String deviceID,
      required String sensorName}) async {
    String? accessToken;
    TokenStatus accessStatus = await _authUtils.verifyToken(token: token);

    if (accessStatus != TokenStatus.valid) {
      Map<String, dynamic> refresh =
          await _sharedPrefsUtils.getTokens(refresh: true);
      accessToken =
          await _authUtils.refreshAccessToken(refresh: refresh['refresh']);
      await _authProvider.setAccess(access: accessToken!);
    }

    final Map<String, dynamic> data = await _apiRequest.put(
        route: _apiRoutes.updateSKName,
        headers: {'Authorization': 'Bearer $token', 'Sensor': deviceID},
        body: sensorName);

    // TODO: HANDLE ERROR SCENARIO
    if (data.containsKey('error')) {
      return data;
    }

    return data;
  }
}
