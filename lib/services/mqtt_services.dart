import 'dart:io';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:smmic/constants/mqtt.dart';
import 'package:smmic/utils/logs.dart';
import 'package:smmic/utils/shared_prefs.dart';

class MqttServices {

  // helpers, configs
  final SharedPrefsUtils _sharedPrefsUtils = SharedPrefsUtils();
  final Logs _logs = Logs(tag: 'MqttServices');

  // constants
  final  _mqttConstants = MqttConstants();

  /// Initializes the MqttServerClient object, connects to the broker and then subscribes to the default topics (and the added topics if any are added).
  ///
  /// Returns a record consisting of the MqttServerClient, a bool indicating if the operation is successful and the exceptions (if any)
  Future<(MqttServerClient, Exception?)> connectClient({
    required String clientIdentifier,
    String? host,
    int? port,
    int? keepAlivePeriod,
    List<String>? topics}) async {

    Exception? exception;

    // client initialization
    final MqttServerClient client = MqttServerClient.withPort(
        host ?? _mqttConstants.broker.hostAddress,
        clientIdentifier,
        port ?? _mqttConstants.broker.port
    );

    // client configurations
    client.setProtocolV311();
    client.logging(on: false);
    client.keepAlivePeriod = keepAlivePeriod ?? 20; // adjust if network connections tend to be unreliable

    // callbacks
    client.onConnected = () {
      _logs.success(message: 'client connected to broker at ${client.server}:${client.port}');
    };
    client.onDisconnected = () {
      _logs.warning(message: 'client disconnected from broker at ${client.server}:${client.port}');
    };
    client.onSubscribed = (topic) {
      _logs.info(message: 'client Subscribed to topic: $topic');
    };

    // connect to broker
    int retries = 3;
    int attempt = 0;
    while (attempt != retries) {
      attempt += 1;
      try {
        await client.connect();
        break;
      } on SocketException catch (e) {
        await Future.delayed(const Duration(seconds: 3));
        exception = e;
      } on Exception catch (e) {
        _logs.error(message: 'unhandled unexpected exception $e raised while attempting to connect to broker}');
        exception = e;
        break;
      }
    }

    // check connection state
    // subscribe to all relevant topics
    if (client.connectionStatus == null) {
      _logs.error(message: 'unhandled unexpected error: client connection status null!');
      client.disconnect();
      exception = Exception('Client connection status null');
    } else if (client.connectionStatus!.state == MqttConnectionState.connected) {
      List<String> additionalTopics = topics ?? <String>[];
      for (String topic in additionalTopics + _mqttConstants.topics.topics) {
        client.subscribe(topic, MqttQos.atLeastOnce);
      }
    }

    return (client, exception);
  }

  String? disconnectClient(MqttServerClient client) {
    String? err;

    if (client.server == '' && client.clientIdentifier == '') {
      err = 'please run MqttProvider.initClient() before any other operation';
    }
    else if (client.connectionStatus == null) {
      err = 'cannot disconnect a client that has a null connectionStatus';
    } else if (client.connectionStatus!.state == MqttConnectionState.disconnected) {
      err = 'client already disconnected';
    } else {
      client.disconnect();
    }

    if (err != null) {
      _logs.error(message: 'disconnectClient() $err');
    }

    return err;
  }
}