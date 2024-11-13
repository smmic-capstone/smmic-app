import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:provider/provider.dart';

class ConnectionProvider extends ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  late Stream<List<ConnectivityResult>> _connectivityStream;

  ConnectivityResult _connectionStatus = ConnectivityResult.none; // ignore: prefer_final_fields
  ConnectivityResult get connectionStatus => _connectionStatus;

  Future<void> init() async {
    _connectivityStream = _connectivity.onConnectivityChanged;
    _connectivityStream.listen((List<ConnectivityResult>connection) async {
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
}