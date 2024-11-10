import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:provider/provider.dart';
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

  Future<void> _init_mqtt({required MqttServerClient client}) async {
    client.setProtocolV311();
    client.logging(on: false);
    client.onSubscribed = (topic) {
      _logs.success(message: 'Subscribed to topic: $topic');
    };
    client.keepAlivePeriod = 20;
    client.onDisconnected = () => {};
    client.onConnected = () => {};
    // final connMess = MqttConnectMessage()
    //     .withClientIdentifier('Mqtt_MyClientUniqueIdQ1')
    //     .withWillTopic('smmic/sink/alert') // If you set this you must set a will message
    //     .withWillMessage('My Will message')
    //     .startClean() // Non persistent session for testing
    //     .withWillQos(MqttQos.atLeastOnce);
    // client.connectionMessage = connMess;

    try {
      await client.connect();
    } on Exception catch (e) {
      _logs.error(message: 'Client exception raised: $e');
      client.disconnect();
    }

    if (client.connectionStatus == null){
      return;
    }

    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      _logs.success(message: 'Client connected to broker at: ${client.server}:${client.port}');

      // subscribe to topics:
      client.subscribe('smmic/sensor/data', MqttQos.atMostOnce);
      client.updates!.listen((messages) {
        final MqttReceivedMessage msg = messages[0];
        if (msg is! MqttReceivedMessage<MqttPublishMessage>) return;
        final payload = MqttPublishPayload.bytesToStringAsString(msg.payload.payload.message);
        _logs.info(message: 'Message received from ${msg.topic}: $payload');
      });

      final builder1 = MqttClientPayloadBuilder();
      builder1.addString('soil_moisture;fd7b1df2-3822-425c-b4c3-e9859251728d;2024-11-10T14:30:00;soil_moisture:0&humidity:0&temperature:0&battery_level:0');
      client.publishMessage('smmic/sensor/data', MqttQos.atMostOnce, builder1.payload!);

      await MqttUtilities.asyncSleep(60);
    }

  }

  @override
  void initState() {
    _init_mqtt(client: mqttClient);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect Locally'),
        centerTitle: true,
      ),
      body: Container(
          color: context.watch<UiProvider>().isDark ? Colors.black : Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Container(
            color: Colors.red,
          )
      ),
    );
  }

}