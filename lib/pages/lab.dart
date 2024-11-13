import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:provider/provider.dart';
import 'package:smmic/providers/connections_provider.dart';

class ConnectivityExample extends StatefulWidget {
  @override
  _ConnectivityExampleState createState() => _ConnectivityExampleState();
}

class _ConnectivityExampleState extends State<ConnectivityExample> {

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Connectivity Example")),
      body: Center(
        child: Text(
          getTextDisplay(context.watch<ConnectionProvider>().connectionStatus),
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  String getTextDisplay(ConnectivityResult res) {
    String fString = 'Unknown Connection';
    switch (res) {
      case ConnectivityResult.wifi:
        fString = 'Connected to Wifi';
        break;
      case ConnectivityResult.mobile:
        fString = 'Connected to Mobile Network';
        break;
      default:
        fString = 'Disconnected';
        break;
    }
    return fString;
  }
}