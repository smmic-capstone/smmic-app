import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:provider/provider.dart';
import 'package:smmic/providers/mqtt_provider.dart';
import 'package:smmic/providers/theme_provider.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:smmic/utils/logs.dart';

class LocalConnect extends StatefulWidget {
  const LocalConnect({super.key});

  @override
  State<LocalConnect> createState() => _LocalConnectState();
}

class _LocalConnectState extends State<LocalConnect> {
  // configurations, utilities
  final Logs _logs = Logs(tag: 'MqttConnect');

  // mqtt setup
  final mqttClient = MqttServerClient('10.0.2.2', '');

  // vars
  // ignore: prefer_final_fields
  MqttConnectionState _mqttConnectionState = MqttConnectionState.disconnected;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect Locally'),
        centerTitle: true,
      ),
      body: Container(
          color: context.watch<UiProvider>().isDark ? Colors.black : Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 30),
          alignment: Alignment.center,
          child: Container(
            width: 0.90 * w,
            color: Colors.red,
            child: Column(
              children: [
                ElevatedButton(
                    onPressed: () async {
                      MqttConnectionState connectionState = context.read<MqttProvider>().connectionState;
                      if (connectionState == MqttConnectionState.connected){
                        context.read<MqttProvider>().disconnectClient();
                      }
                      else if ([MqttConnectionState.disconnected, MqttConnectionState.faulted].contains(connectionState)) {
                        Exception? err = await context.read<MqttProvider>().initClient(clientIdentifier: '');
                        if (err != null && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Unable to connect to broker, try again later'))
                          );
                        }
                      }
                    },
                    child: Text(
                      _connectButtonState(context.watch<MqttProvider>().connectionState),
                      style: _connectButtonTextStyle(
                          context.watch<MqttProvider>().connectionState,
                          context.watch<UiProvider>().isDark
                      ),
                    )
                )
              ],
            ),
          )
      )
    );
  }

  String _connectButtonState(MqttConnectionState connState) {
    String buttonText = 'Connect';
    if (connState == MqttConnectionState.connecting) {
      buttonText = 'Connecting';
    } else if (connState == MqttConnectionState.disconnecting) {
      buttonText = 'Disconnecting';
    } else if (connState == MqttConnectionState.connected) {
      buttonText = 'Connected';
    }
    return buttonText;
  }

  TextStyle _connectButtonTextStyle(MqttConnectionState connState, bool isDark) {
    TextStyle style = const TextStyle();
    if (connState == MqttConnectionState.connecting) {
      double opacity = 0.4;
      style = TextStyle(color: isDark ? Colors.white.withOpacity(opacity) : Colors.black.withOpacity(opacity));
    }
    return style;
  }

}