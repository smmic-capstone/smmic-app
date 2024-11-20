import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:smmic/constants/api.dart';
import 'package:smmic/models/device_data_models.dart';
import 'package:smmic/providers/connections_provider.dart';
import 'package:smmic/providers/devices_provider.dart';
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
  irrigationCommand("irrigation"),
  intervalCommand("interval");

  final String events;
  const EventNames(this.events);
}

class ApiRequest {
  final Logs _logs = Logs(tag: 'ApiRequest()');

  // dependencies / helpers
  final ApiRoutes _apiRoutes = ApiRoutes();
  final PusherChannelsFlutter _pusher = PusherChannelsFlutter();

  late BuildContext _internalBuildContext;

  PusherChannelsFlutter get pusher => _pusher;

  // connections that are used to connect to the api / mqtt network
  final List<ConnectivityResult> _sourceConnections = [
    ConnectivityResult.mobile,
    ConnectivityResult.wifi
  ];

  Future<Map<String, dynamic>> _request(
      {required String route,
      required Either<
              Future<http.Response> Function(Uri,
                  {Object? body,
                  Encoding? encoding,
                  Map<String, String>? headers}),
              Future<http.Response> Function(Uri,
                  {Map<String, String>? headers})>
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
          _logs.error(
              message: 'post() $route, returned with error $statusCode');
          finalRes.addAll({'error': statusCode});
          break;

        case (400):
          _logs.warning(
              message: 'post() $route, returned with error $statusCode');
          finalRes.addAll({'error': statusCode});
          break;

        case (401):
          _logs.warning(
              message: 'post() $route, returned with error $statusCode');
          finalRes.addAll({'error': statusCode});
          break;

        case (200):
          _logs.success(
              message: 'post() $route, returned with data $statusCode');
          break;
      }

      finalRes.addAll({
        'status_code': statusCode,
        'body': resBody,
        'data': jsonDecode(resBody)
      });
    } on http.ClientException catch (e) {
      _logs.warning(message: 'request() raised ClientException -> $e');
      finalRes.addAll({'status_code': 0});
    } catch (e) {
      _logs.warning(
          message:
              'post() unhandled unexpected post() error (statusCode: $statusCode, body: $resBody)');
    }

    return finalRes;
  }

  /// Get request for api, returns a the response status code and the body if available
  Future<dynamic> get(
      {required String route, Map<String, String>? headers}) async {
    _logs.info(message: 'get() $route, headers: ${headers ?? 'none'}');

    Map<String, dynamic> result = await _request(
      route: route,
      method: right(http.get),
      headers: headers,
    );

    return result;
  }

  Future<Map<String, dynamic>> post(
      {required String route,
      Map<String, String>? headers,
      Object? body}) async {
    _logs.info(
        message: 'post() -> route: $route, headers: $headers, body: $body');

    Map<String, dynamic> result = await _request(
        route: route, method: left(http.post), headers: headers, body: body);

    return result;
  }

  Future<Map<String, dynamic>> put(
      {required String route,
      Map<String, String>? headers,
      Object? body}) async {
    _logs.info(
        message:
            'put() $route, headers: ${headers ?? 'none'}, body: ${body ?? 'none'}');

    Map<String, dynamic> result = await _request(
        route: route, method: left(http.put), headers: headers, body: body);

    return result;
  }

  Future<Map<String, dynamic>> patch(
      {required String route,
      Map<String, String>? headers,
      Object? body}) async {
    _logs.info(
        message:
            'patch() $route, headers: ${headers ?? 'none'}, body: ${body ?? 'none'}');

    Map<String, dynamic> result = await _request(
        route: route, method: left(http.patch), headers: headers, body: body);

    return result;
  }

  ///user_commands
  ///irrigation
  Future<void> openCommandsConnection() async {
    await _pusher.init(
      apiKey: 'd0f649dd91498f8916b8',
      cluster: 'ap3',
    );

    try {
      await _pusher.subscribe(channelName: "user_commands");

      await _pusher.connect();

      _logs.info(message: "WebSocket Connected in user_commands");
    } catch (e) {
      _logs.warning(message: "WebSocketException: $e");
    }
  }

  Future<void> sendCommand(
      {required String eventName, required int code}) async {
    /*await _pusher.init(
      apiKey: 'd0f649dd91498f8916b8',
      cluster: 'ap3',
    );

    try{
      await _pusher.subscribe(
          channelName: "user_commands");

      await _pusher.connect();

      _logs.info(message: "WebSocket Connected in user_commands");
    }catch(e){
      _logs.warning(message: "WebSocketException: $e");
    }*/

    await _pusher.trigger(PusherEvent(
        channelName: "user_commands", eventName: eventName, data: code));

    /*_pusher.trigger(PusherEvent(
        channelName: "user_commands",
        eventName: eventName,
        data: {
          "message" : code
        }),
    );*/
  }

  //Open connection to Channels
  Future<void> openConnection(BuildContext context) async {
    _internalBuildContext = context;

    await _pusher.init(
      apiKey: 'd0f649dd91498f8916b8',
      cluster: 'ap3',
    );
    try {
      await _pusher.subscribe(
          channelName: _apiRoutes.seReadingsWs,
          onEvent: (dynamic data) {
            _seReadingsWsListener(data as PusherEvent);
          });

      await _pusher.subscribe(
          channelName: _apiRoutes.seAlertsWs,
          onEvent: (dynamic data) {
            _seAlertsWsListener(data as PusherEvent);
          });

      await _pusher.connect();

      _logs.info(message: "WebSocket Connected");
    } catch (e) {
      _logs.warning(message: "WebSocketException: $e");
    }
  }

  // the internal websocket listener wrapper function for
  // the sensor readings websocket
  void _seReadingsWsListener(PusherEvent data) {
    final Map<String, dynamic> decodedData = jsonDecode(data.data);

    final SensorNodeSnapshot snapshotObj =
        SensorNodeSnapshot.fromJSON(decodedData['message']);
    _logs.warning(message: "snapshotObj: $snapshotObj");
    // store data to sqlite database
    DatabaseHelper.readingsLimit(snapshotObj.deviceID);
    DatabaseHelper.addReadings(snapshotObj);

    // pass to stream controller
    // streamController.add(snapshotObj);
    _internalBuildContext
        .read<DevicesProvider>()
        .setNewSensorSnapshot(snapshotObj);

    /*channel.sink.close();
      _logs.warning(message: '_seReadingsWsListener() error in stream.listen : $err');
      context.read<ConnectionProvider>().sensorWsConnectStatus(WsConnectionStatus.disconnected);


      channel.sink.close();
      context.read<ConnectionProvider>().sensorWsConnectStatus(WsConnectionStatus.disconnected);*/
  }

  /// Initialize connection with the sensor node alert WebSocket
  /*Future<void> initSeAlertsWSChannel() async {
    // attempt websocket connection
    void onEventCallback(PusherEvent data){
      _seAlertsWsListener(data, context);
    }

    PusherChannel? seAlertsWebSocket = await _connectChannel(_apiRoutes.seAlertsWs, onEventCallback);
    if (seAlertsWebSocket == null) {
      return;
    }

    */ /*context.read<ConnectionProvider>().alertWsConnectStatus(WsConnectionStatus.connected);*/ /*
    */ /*_wsConnectionManager(context, route, seAlertsWebSocket, _seAlertsWsListener);*/ /*
    return;
  }*/

  // listener wrapper function for the sensor node alerts websocket
  void _seAlertsWsListener(PusherEvent data) {
    final Map<String, dynamic> decodedData = jsonDecode(data.data);
    final SensorNodeSnapshot snapshotObj =
        SensorNodeSnapshot.fromJSON(decodedData['message']);

    // store data to sqlite
    DatabaseHelper.readingsLimit(snapshotObj.deviceID);
    DatabaseHelper.addReadings(snapshotObj);

    // pass to stream controller
    //streamController.add(alertObj);

    _internalBuildContext
        .read<DevicesProvider>()
        .setNewSensorSnapshot(snapshotObj);
    _internalBuildContext
        .read<DevicesProvider>()
        .updateSMSensorState(decodedData['message']);

    /* channel.sink.close();
      _logs.warning(message: '_seAlertsWsListener() error in stream.listen : $err');
      context.read<ConnectionProvider>()
          .alertWsConnectStatus(WsConnectionStatus.disconnected);


      channel.sink.close();
      context.read<ConnectionProvider>()
          .alertWsConnectStatus(WsConnectionStatus.disconnected);*/
  }
}
