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
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

class ApiRequest {
  final Logs _logs = Logs(tag: 'ApiRequest()');

  // dependencies / helpers
  final ApiRoutes _apiRoutes = ApiRoutes();

  // connections that are used to connect to the api / mqtt network
  final List<ConnectivityResult> _sourceConnections = [
    ConnectivityResult.mobile,
    ConnectivityResult.wifi
  ];
  
  Future<Map<String, dynamic>> _request({
    required String route,
    required Either<
      Future<http.Response>Function(Uri, {Object? body, Encoding? encoding, Map<String, String>? headers}),
      Future<http.Response>Function(Uri, {Map<String, String>? headers})> method,
    Map<String, String>? headers,
    Object? body}) async {

    http.Response? res;
    int? statusCode;
    String? resBody;

    Map<String, dynamic> finalRes = {};

    try {
      res = await method.fold(
          (method1) => method1(
              Uri.parse(route),
              headers: headers,
              body: body),
          (method2) => method2(
            Uri.parse(route),
            headers: headers),
      );

      if (res == null) {
        throw Exception('unhandled unexpected error -> request result null');
      }

      statusCode = res.statusCode;
      resBody = res.body;

      switch (statusCode) {
        case (500):
          _logs.error(message:'post() $route, returned with error $statusCode');
          finalRes.addAll({'error' : statusCode});
          break;

        case (400):
          _logs.warning(message:'post() $route, returned with error $statusCode');
          finalRes.addAll({'error' : statusCode});
          break;

        case (401):
          _logs.warning(message:'post() $route, returned with error $statusCode');
          finalRes.addAll({'error' : statusCode});
          break;

        case (200):
          _logs.success(message:'post() $route, returned with data $statusCode');
          break;
      }

      finalRes.addAll({
        'status_code': statusCode,
        'body': resBody,
        'data': jsonDecode(resBody)
      });

    } on http.ClientException catch (e) {
      _logs.warning(message: 'request() raised ClientException -> $e');
      finalRes.addAll({
        'status_code': 0
      });

    } catch (e) {
      _logs.warning(message:'post() unhandled unexpected post() error (statusCode: $statusCode, body: $resBody)');
    }

    return finalRes;
  }

  /// Get request for api, returns a the response status code and the body if available
  Future<dynamic> get({
    required String route,
    Map<String,String>? headers }) async {

    _logs.info(message: 'get() $route, headers: ${headers ?? 'none'}');

    Map<String, dynamic> result = await _request(
        route: route,
        method: right(http.get),
        headers: headers,
    );

    return result;
  }

  Future<Map<String, dynamic>> post({
    required String route,
    Map<String, String>? headers,
    Object? body }) async {

    _logs.info(message: 'post() -> route: $route, headers: $headers, body: $body');

    Map<String, dynamic> result = await _request(
        route: route,
        method: left(http.post),
        headers: headers,
        body: body
    );

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
        route: route,
        method: left(http.put),
        headers: headers,
        body: body
    );

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
        route: route,
        method: left(http.patch),
        headers: headers,
        body: body
    );

    return result;
  }

  // abstract websocket connect function
  // returns the websocket channel instance
  WebSocketChannel? _connectChannel(String route) {

    WebSocketChannel? channel;
    try {
      channel = WebSocketChannel.connect(Uri.parse(route));
      return channel;
    } on WebSocketChannelException catch (e) {
      _logs.warning(message: '_connectChannel() called WebSocketChannelException : $route -> $e');
    } on Exception catch (e) {
      _logs.warning(message: '_connectChannel() unhandled unexpected exception raised : $route -> $e');
    }
    return channel;
  }

  // abstract websocket connection manager
  void _wsConnectionManager(
      BuildContext context,
      String route,
      WebSocketChannel channel,
      void Function(WebSocketChannel, BuildContext) listener) async {

    WebSocketChannel wsChannel = channel;
    listener(wsChannel, context);

    // listen to the connectivity stream for updates
    // on available connections
    Stream<List<ConnectivityResult>> connectivityStream = context.read<ConnectionProvider>().connectivityStream;
    connectivityStream.listen((List<ConnectivityResult> connection) {
      // when the stream updates, check the list of connectivity result for
      // presence of any of the source connections
      // if it contains at least one, allow connect attempt of ws
      bool sourceAvailable = false;
      for (ConnectivityResult source in _sourceConnections) {
        if (connection.contains(source)) {
          sourceAvailable = true;
          break;
        }
      }

      WsConnectionStatus? connectionStatus;

      if (route == _apiRoutes.seReadingsWs) {
        connectionStatus = context.read<ConnectionProvider>().seReadingsWsConnectionStatus;
      } else if (route == _apiRoutes.seAlertsWs) {
        connectionStatus = context.read<ConnectionProvider>().seAlertsWsConnectionStatus;
      }

      // check the connection status
      if (!sourceAvailable && connectionStatus == WsConnectionStatus.connected) {
        wsChannel.sink.close();
        return;
      } else if (!sourceAvailable) {
        wsChannel.sink.close();
        return;
      }

      try{
        wsChannel = WebSocketChannel.connect(Uri.parse(route));

        if (route == _apiRoutes.seReadingsWs) {
          context.read<ConnectionProvider>().sensorWsConnectStatus(WsConnectionStatus.connected);
        } else if (route == _apiRoutes.seAlertsWs) {
          context.read<ConnectionProvider>().alertWsConnectStatus(WsConnectionStatus.connected);
        }

      } on WebSocketChannelException catch (e) {
        _logs.warning(message: 'connectSeReadingsChannel() called WebSocketChannelException : $route -> $e');
      } on Exception catch (e) {
        _logs.warning(message: 'connectSeReadingsChannel() unhandled unexpected exception raised : $route -> $e');
      }

      listener(wsChannel, context);

    });

  }

  /// Initialize connection with the sensor readings WebSocket
  void initSeReadingsWSChannel({required String route, required BuildContext context}) {
    // attempt connection with the websocket
    WebSocketChannel? seReadingsWebSocket = _connectChannel(route);
    if (seReadingsWebSocket == null) {
      return;
    }

    context.read<ConnectionProvider>().sensorWsConnectStatus(WsConnectionStatus.connected);
    _wsConnectionManager(context, route, seReadingsWebSocket, _seReadingsWsListener);
    return;
  }

  // the internal websocket listener wrapper function for
  // the sensor readings websocket
  void _seReadingsWsListener(WebSocketChannel channel, BuildContext context) {
    channel.stream.listen((data) {
      final Map<String, dynamic> decodedData = jsonDecode(data);
      final SensorNodeSnapshot snapshotObj = SensorNodeSnapshot.fromJSON(decodedData['message']);

      // store data to sqlite database
      DatabaseHelper.readingsLimit(snapshotObj.deviceID);
      DatabaseHelper.addReadings(snapshotObj);

      // pass to stream controller
      // streamController.add(snapshotObj);
      context.read<DevicesProvider>().setNewSensorSnapshot(snapshotObj);

    }, onError: (err) {
      channel.sink.close();
      _logs.warning(message: '_seReadingsWsListener() error in stream.listen : $err');
      context.read<ConnectionProvider>().sensorWsConnectStatus(WsConnectionStatus.disconnected);

    }, onDone: () {
      channel.sink.close();
      context.read<ConnectionProvider>().sensorWsConnectStatus(WsConnectionStatus.disconnected);

    });
  }

  /// Initialize connection with the sensor node alert WebSocket
  void initSeAlertsWSChannel({required String route, required BuildContext context}) {
    // attempt websocket connection
    WebSocketChannel? seAlertsWebSocket = _connectChannel(route);
    if (seAlertsWebSocket == null) {
      return;
    }

    context.read<ConnectionProvider>().alertWsConnectStatus(WsConnectionStatus.connected);
    _wsConnectionManager(context, route, seAlertsWebSocket, _seAlertsWsListener);
    return;
  }

  // listener wrapper function for the sensor node alerts websocket
  void _seAlertsWsListener(WebSocketChannel channel, BuildContext context) {
    channel.stream.listen((data) {
      final Map<String, dynamic> decodedData = jsonDecode(data);
      final SensorNodeSnapshot snapshotObj = SensorNodeSnapshot.fromJSON(decodedData['message']);

      // store data to sqlite
      DatabaseHelper.readingsLimit(snapshotObj.deviceID);
      DatabaseHelper.addReadings(snapshotObj);

      // pass to stream controller
      //streamController.add(alertObj);

      context.read<DevicesProvider>().setNewSensorSnapshot(snapshotObj);
      context.read<DevicesProvider>().updateSMSensorState(decodedData);

    }, onError: (err) {
      channel.sink.close();
      _logs.warning(message: '_seAlertsWsListener() error in stream.listen : $err');
      context.read<ConnectionProvider>()
          .alertWsConnectStatus(WsConnectionStatus.disconnected);

    }, onDone: () {
      channel.sink.close();
      context.read<ConnectionProvider>()
          .alertWsConnectStatus(WsConnectionStatus.disconnected);

    });
  }

}
