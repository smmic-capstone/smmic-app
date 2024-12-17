import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smmic/constants/api.dart';
import 'package:smmic/models/device_data_models.dart';
import 'package:smmic/providers/connections_provider.dart';
import 'package:smmic/providers/devices_provider.dart';
import 'package:smmic/pusher/pusherservices.dart';
import 'package:smmic/sqlitedb/db.dart';
import 'package:smmic/utils/logs.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

enum Commands {
  irrigationOFF(0),
  irrigationON(1),
  interval(69);

  final int command;
  const Commands(this.command);
}

enum EventNames {
  irrigationCommand("client-irrigation"),
  intervalCommand("client-interval");

  final String events;
  const EventNames(this.events);
}

class ApiRequest {
  final Logs _logs = Logs(tag: 'ApiRequest()');
  final PusherServices _pusherAuth = PusherServices();

  // dependencies / helpers
  final ApiRoutes _apiRoutes = ApiRoutes();
  final PusherChannelsFlutter _pusher = PusherChannelsFlutter();

  late BuildContext _internalBuildContext;

  PusherChannelsFlutter get pusher => _pusher;

  // connections that are used to connect to the api / mqtt network
  final List<ConnectivityResult> _sourceConnections = [ConnectivityResult.mobile, ConnectivityResult.wifi];

  Future<Map<String, dynamic>> _request(
      {required String route,
      required Either<Future<http.Response> Function(Uri, {Object? body, Encoding? encoding, Map<String, String>? headers}),
              Future<http.Response> Function(Uri, {Map<String, String>? headers})>
          method,
      Map<String, String>? headers,
      Object? body}) async {
    http.Response? res;
    int? statusCode;
    String? resBody;

    Map<String, dynamic> finalRes = {};

    try {
      res = await method.fold(
        (method1) => method1(Uri.parse(route), headers: headers, body: body),
        (method2) => method2(Uri.parse(route), headers: headers),
      );

      if (res == null) {
        throw Exception('unhandled unexpected error -> request result null');
      }

      statusCode = res.statusCode;
      resBody = res.body;

      switch (statusCode) {
        case (500):
          _logs.error(message: 'post() $route, returned with error $statusCode');
          finalRes.addAll({'error': statusCode});
          break;

        case (400):
          _logs.warning(message: 'post() $route, returned with error $statusCode');
          finalRes.addAll({'error': statusCode});
          break;

        case (401):
          _logs.warning(message: 'post() $route, returned with error $statusCode');
          finalRes.addAll({'error': statusCode});
          break;

        case (200):
          _logs.success(message: 'post() $route, returned with data $statusCode');
          break;

        case (204):
          _logs.success(message: 'post() $route, return with data $statusCode');
          break;

        case (201):
          _logs.success(message: 'post() $route, return with data $statusCode');
          break;
      }

      finalRes.addAll({'status_code': statusCode, 'body': resBody, 'data': jsonDecode(resBody != '' ? resBody : '{}')});
    } on http.ClientException catch (e) {
      _logs.warning(message: 'request() raised ClientException -> $e');
      finalRes.addAll({'status_code': 0});
    } catch (e) {
      print(e);
      _logs.warning(message: 'patch() unhandled unexpected post() error (statusCode: $statusCode, body: $resBody)');
    }

    return finalRes;
  }

  /// Get request for api, returns a the response status code and the body if available
  Future<dynamic> get({required String route, Map<String, String>? headers}) async {
    _logs.info(message: 'get() $route, headers: ${headers ?? 'none'}');

    Map<String, dynamic> result = await _request(
      route: route,
      method: right(http.get),
      headers: headers,
    );

    return result;
  }

  Future<Map<String, dynamic>> post({required String route, Map<String, String>? headers, Object? body}) async {
    _logs.info(message: 'post() -> route: $route, headers: $headers, body: $body');

    Map<String, dynamic> result = await _request(route: route, method: left(http.post), headers: headers, body: body);

    _logs.info(message: result.toString());

    return result;
  }

  Future<Map<String, dynamic>> put({required String route, Map<String, String>? headers, Object? body}) async {
    _logs.info(message: 'put() $route, headers: ${headers ?? 'none'}, body: ${body ?? 'none'}');

    Map<String, dynamic> result = await _request(route: route, method: left(http.put), headers: headers, body: body);

    return result;
  }

  Future<Map<String, dynamic>> patch({required String route, Map<String, String>? headers, Object? body}) async {
    _logs.info(message: 'patch() $route, headers: ${headers ?? 'none'}, body: ${body ?? 'none'}');

    Map<String, dynamic> result = await _request(route: route, method: left(http.patch), headers: headers, body: body);

    return result;
  }

  ///Pusher Connection and Events below here

  //Open connection to Channels
  Future<void> openConnection(BuildContext context) async {
    _internalBuildContext = context;
    _logs.warning(message: "openConnection running");

    void onSubError(String channelName) {
      _logs.warning(message: 'failed subscription to channel -> $channelName');
    }

    void onSubSucceeded(String channelName) {
      _logs.info2(message: 'subscribed to channel -> $channelName');
      context.read<ConnectionProvider>().updateChannelSubState(channelName, true);
    }

    try {
      await _pusher.init(apiKey: 'd0f649dd91498f8916b8', cluster: 'ap3', onAuthorizer: onAuthorizer);

      await _pusher.connect();

      ///Pusher commands channels
      await _pusher.subscribe(
          channelName: _apiRoutes.userCommands,
          onEvent: (dynamic data) {
            _userCommandsFeedbackListener(data as PusherEvent);
          },
          onSubscriptionSucceeded: ((dynamic) => onSubSucceeded(_apiRoutes.userCommands)),
          onSubscriptionError: ((dynamic) => onSubError(_apiRoutes.userCommands)));

      ///Pusher readings channels
      await _pusher.subscribe(
          channelName: _apiRoutes.seReadingsWs,
          onEvent: (dynamic data) {
            _seReadingsWsListener(data as PusherEvent);
          },
          onSubscriptionSucceeded: ((dynamic) => onSubSucceeded(_apiRoutes.seReadingsWs)),
          onSubscriptionError: ((dynamic) => onSubError(_apiRoutes.seReadingsWs)));

      ///Pusher alerts channels
      await _pusher.subscribe(
          channelName: _apiRoutes.seAlertsWs,
          onEvent: (dynamic data) {
            _seAlertsWsListener(data as PusherEvent);
          },
          onSubscriptionSucceeded: ((dynamic) => onSubSucceeded(_apiRoutes.seAlertsWs)),
          onSubscriptionError: ((dynamic) => onSubError(_apiRoutes.seAlertsWs)));

      await _pusher.subscribe(
          channelName: _apiRoutes.sinkReadingsWs,
          onEvent: (dynamic data) {
            _sinkSnapshotListener(data as PusherEvent);
          },
          onSubscriptionSucceeded: ((dynamic) => onSubSucceeded(_apiRoutes.sinkReadingsWs)),
          onSubscriptionError: ((dynamic) => onSubError(_apiRoutes.sinkReadingsWs)));

      await pusher.subscribe(
        channelName: _apiRoutes.userCommands,
        onEvent: (dynamic data) {
          final event = data as PusherEvent;
          if (event.eventName == 'commands-success') {
            _commandsSuccessListener(event);
          }
        },
        onSubscriptionSucceeded: ((dynamic) => onSubSucceeded(_apiRoutes.userCommands)),
        onSubscriptionError: ((dynamic) => onSubSucceeded(_apiRoutes.userCommands)),
      );

      await _pusher.connect();
    } catch (e) {
      _logs.warning(message: "WebSocketException: $e");
    }
    _logs.warning(message: "pusher connection state ${_pusher.connectionState}");
  }

  dynamic onAuthorizer(String channelName, String socketId, dynamic options) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? accessToken = sharedPreferences.getString('access');
    String authURL = _apiRoutes.pusherAuth;
    final response = await post(route: authURL, headers: {
      'Authorization': 'Bearer $accessToken'
    }, body: {
      'socket_id': socketId,
      'channel_name': channelName,
    });
    final jsonResponse = jsonDecode(response['body']);
    _logs.warning(message: "$jsonResponse");
    return jsonResponse;
  }

  Future<void> sendIntervalCommand({String eventName = 'client-interval', required Duration newInterval, required String deviceId}) async {
    Map<String, dynamic> commandData = {SensorNodeKeys.deviceID.key: deviceId, 'interval': newInterval.inSeconds};

    await _pusher.trigger(PusherEvent(channelName: _apiRoutes.userCommands, eventName: eventName, data: jsonEncode(commandData)));
  }

  Future<void> sendIrrigationCommand({String eventName = 'client-irrigation', required String deviceId, required int command}) async {
    Map<String, dynamic> commandData = {
      SensorNodeKeys.deviceID.key: deviceId,
      'command': command,
    };

    try {
      await _pusher.trigger(PusherEvent(
          channelName: _apiRoutes.userCommands,
          eventName: eventName,
          //data: '$deviceId;$command;${DateTime.now()}'
          data: jsonEncode(commandData)));
    } catch (e) {
      _logs.error(message: e.toString());
    }
  }

  void _commandsSuccessListener(PusherEvent data) {
    final Map<String, dynamic> decodedData = jsonDecode(data.data);
    _logs.info(message: "commandsData : $decodedData");
  }

  // the internal websocket listener wrapper function for
  // the sensor readings websocket
  void _seReadingsWsListener(PusherEvent data) {
    final Map<String, dynamic> decodedData = jsonDecode(data.data);

    final SensorNodeSnapshot snapshotObj = SensorNodeSnapshot.fromJSON(decodedData['message']);

    // pass to stream controller
    // streamController.add(snapshotObj);
    _internalBuildContext.read<DevicesProvider>().setNewSensorSnapshot(snapshotObj);
  }

  // listener wrapper function for the sensor node alerts websocket
  void _seAlertsWsListener(PusherEvent data) {
    final Map<String, dynamic> decodedData = jsonDecode(data.data);

    if ((decodedData['message'] as Map<String, dynamic>)['data'] != {}) {
      final SensorNodeSnapshot snapshotObj = SensorNodeSnapshot.fromJSON(decodedData['message']);

      // store data to sqlite
      DatabaseHelper.readingsLimit(snapshotObj.deviceID);
      DatabaseHelper.addReadings([snapshotObj]);

      // updated sensor snapshot
      _internalBuildContext.read<DevicesProvider>().setNewSensorSnapshot(snapshotObj);
    }

    // update sensor state
    _internalBuildContext.read<DevicesProvider>().updateSMSensorState(decodedData['message']);
  }

  void _sinkSnapshotListener(PusherEvent data) {
    final Map<String, dynamic> decodedData = jsonDecode(data.data);
    final Map<String, dynamic> sinkSnapshotMap = decodedData['message'];
    _logs.warning(message: sinkSnapshotMap.toString());
    _internalBuildContext.read<DevicesProvider>().updateSinkState(sinkSnapshotMap);
  }

  void _userCommandsFeedbackListener(PusherEvent data) {
    if (data.eventName == 'commands-feedback') {
      final Map<String, dynamic> decodedData = jsonDecode(data.data);
      _logs.warning(message: decodedData.toString());
      Map<String, dynamic> asMap = {
        SensorAlertKeys.deviceID.key: decodedData[SensorAlertKeys.deviceID.key],
        SensorAlertKeys.alertCode.key: '1${decodedData['command']}',
        SensorAlertKeys.timestamp.key: decodedData['timestamp'],
        SensorAlertKeys.data.key: {}
      };
      _internalBuildContext.read<DevicesProvider>().updateSMSensorState(asMap);
    }
  }
}
