import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:provider/provider.dart';

enum WsConnectionStatus {
  disconnected,
  connected
}

class ConnectionProvider extends ChangeNotifier {
  // the current connectivity of the device
  ConnectivityResult _connectionStatus = ConnectivityResult.none; // ignore: prefer_final_fields
  ConnectivityResult get connectionStatus => _connectionStatus;

  // ignore: prefer_final_fields
  Stream<List<ConnectivityResult>> _connectivityStream = Connectivity().onConnectivityChanged;
  Stream<List<ConnectivityResult>> get connectivityStream => _connectivityStream;
  void init() {
    _connectivityStream.listen((List<ConnectivityResult> connection) {
      switch (connection[0]) {

        case ConnectivityResult.wifi:
          _connectionStatus = ConnectivityResult.wifi;
          break;

        case ConnectivityResult.mobile:
          _connectionStatus = ConnectivityResult.mobile;
          break;

        default:
          _connectionStatus = ConnectivityResult.none;
          break;
      }

      notifyListeners();
    });
  }

  // sensor readings web socket connection status
  // ignore: prefer_final_fields
  WsConnectionStatus _seWsConnectionStatus = WsConnectionStatus.disconnected;
  WsConnectionStatus get seReadingsWsConnectionStatus => _seWsConnectionStatus;
  void sensorWsConnectStatus(WsConnectionStatus connectionStatus) {
    _seWsConnectionStatus = connectionStatus;
    notifyListeners();
  }

  // alerts web socket connection status
  // ignore: prefer_final_fields
  WsConnectionStatus _alertsConnectionStatus = WsConnectionStatus.disconnected;
  WsConnectionStatus get seAlertsWsConnectionStatus => _alertsConnectionStatus;
  void alertWsConnectStatus(WsConnectionStatus connectionStatus) {
    _seWsConnectionStatus = connectionStatus;
    notifyListeners();
  }

}