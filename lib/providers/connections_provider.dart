import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:provider/provider.dart';
import 'package:smmic/utils/api.dart';
import 'package:smmic/utils/logs.dart';

class ConnectionProvider extends ChangeNotifier {
  // helpers, configs
  final Logs _log = Logs(tag: 'Connection Provider');
  final ApiRequest _apiRequest = ApiRequest();
  
  // the current connectivity of the device
  ConnectivityResult _connectionStatus = ConnectivityResult.none; // ignore: prefer_final_fields
  ConnectivityResult get connectionStatus => _connectionStatus;

  final List<ConnectivityResult> _sourceConnections = [
    ConnectivityResult.wifi,
    ConnectivityResult.mobile
  ];

  final Stream<List<ConnectivityResult>> _connectivityStream = Connectivity()
      .onConnectivityChanged;

  bool _deviceIsConnected = false; // ignore: prefer_final_fields
  bool get deviceIsConnected => _deviceIsConnected;

  Future<void> init(BuildContext context) async {
    _connectivityStream.listen(_connectivityListener);
    //await _apiRequest.openConnection(context);
    await _apiRequest.openConnection(context);
  }

  void _connectivityListener(List<ConnectivityResult> connections) {
    bool onChangedConnected;

    if (connections.any((con) => _sourceConnections.contains(con))) {
      onChangedConnected = true;
    } else {
      onChangedConnected = false;
    }

    if (onChangedConnected != _deviceIsConnected) {
      if (!onChangedConnected) {
        _log.error(message: 'Device not connected on any of the source connections');
      } else {
        _log.info2(message: 'Device is connected');
      }
      _deviceIsConnected = onChangedConnected;
      notifyListeners();
    }
  }

  Map<String, bool> _channelsSubStateMap = {}; // ignore: prefer_final_fields
  Map<String, bool> get channelsSubStateMap => _channelsSubStateMap;
  
  void updateChannelSubState(String channelName, bool isConnected) {
    _channelsSubStateMap[channelName] = isConnected;
    notifyListeners();
  }

}