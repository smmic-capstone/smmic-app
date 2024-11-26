import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:provider/provider.dart';
import 'package:smmic/models/device_data_models.dart';
import 'package:smmic/providers/devices_provider.dart';
import 'package:smmic/services/mqtt_services.dart';
import 'package:smmic/sqlitedb/db.dart';
import 'package:smmic/utils/logs.dart';
import 'package:smmic/utils/mqtt_utils.dart';

class MqttProvider extends ChangeNotifier {
  // helpers, configs
  final Logs _logs = Logs(tag: 'MqttProvider');
  final MqttServices _mqttServices = MqttServices();

  // ignore: prefer_final_fields
  MqttServerClient _mqttServerClient = MqttServerClient('', '');
  // ignore: prefer_final_fields
  MqttConnectionState _mqttConnectionState = MqttConnectionState.disconnected;

  MqttServerClient get mqttClient => _mqttServerClient;
  MqttConnectionState get connectionState => _mqttConnectionState;

  // internal context object for mqtt
  BuildContext? _context;

  void registerContext({required BuildContext context}){
    _context = context;
  }

  /// Initializes and connects the MqttClient
  ///
  /// Returns the MqttClient
  Future<Exception?> initClient({
    required String clientIdentifier,
    String? host,
    int? port,
    int? keepAlivePeriod,
    List<String>? topics}) async {

    _mqttConnectionState = MqttConnectionState.connecting;
    notifyListeners();

    (MqttServerClient, Exception?) mqttConnect = await _mqttServices.connectClient(
      clientIdentifier: clientIdentifier,
      host: host,
      port: port,
      keepAlivePeriod: keepAlivePeriod,
      topics: topics
    );

    if (mqttConnect.$2 != null) {
      _logs.error(message: 'mqttServices.connectClient() returned with exceptions: ${mqttConnect.$2}');
    } else {
      _mqttServerClient = mqttConnect.$1;
      _logs.success(message: 'mqtt client init done...');
    }
    _mqttConnectionState = mqttConnect.$1.connectionStatus!.state;

    mqttConnect.$1.updates!.listen((messages) {
      final MqttReceivedMessage<MqttMessage> recMes = messages[0];
      final MqttPublishMessage mes = recMes.payload as MqttPublishMessage;
      final String payload = MqttPublishPayload.bytesToStringAsString(mes.payload.message);

      // store to sqlite
      Map<String, dynamic>? mappedPayload = MqttUtils().mapSensorPayload(payload);
      if (mappedPayload != null) {
        SensorNodeSnapshot snapshot = SensorNodeSnapshot.fromJSON(mappedPayload);

        if (_context != null && _context!.mounted){
          _context!.read<DevicesProvider>().setNewSensorSnapshot(snapshot);
        }
      }
    });

    notifyListeners();
    return mqttConnect.$2;
  }

  /// Disconnects the client.
  ///
  /// Returns a record (`bool`, `String?`), a bool indicating the success of the operation and the cause if the operation failed.
  String? disconnectClient() {
    String? err;
    _mqttServices.disconnectClient(_mqttServerClient);
    _mqttConnectionState = _mqttServerClient.connectionStatus!.state;
    notifyListeners();
    return err;
  }

}