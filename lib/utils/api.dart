import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:smmic/constants/api.dart';
import 'package:smmic/models/device_data_models.dart';
import 'package:smmic/providers/devices_provider.dart';
import 'package:smmic/sqlitedb/db.dart';
import 'package:smmic/utils/logs.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ApiRequest {
  final Logs _logs = Logs(tag: 'ApiRequest()');

  // dependencies / helpers
  final ApiRoutes _apiRoutes = ApiRoutes();

  Future<Map<String, dynamic>> _request({
    required String route,
    required Either<
      Future<http.Response>Function(Uri, {Object? body, Encoding? encoding, Map<String, String>? headers}),
      Future<http.Response>Function(Uri, {Map<String, String>? headers})>
    method,
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
            headers: headers)
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
        case (400):
          _logs.warning(message:'post() $route, returned with error $statusCode');
          finalRes.addAll({'error' : statusCode});
        case (401):
          _logs.warning(message:'post() $route, returned with error $statusCode');
          finalRes.addAll({'error' : statusCode});
        case (200):
          _logs.success(message:'post() $route, returned with data $statusCode');
          finalRes.addAll({
            'status_code': statusCode,
            'body': resBody,
            'data': jsonDecode(resBody)
          });
      }
    } on http.ClientException catch (e) {
      _logs.warning(message: 'post() raised ClientException -> $e');
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
          'put() $route, headers: ${headers ?? 'none'}, body: ${body ?? 'none'}');

    Map<String, dynamic> result = await _request(
        route: route,
        method: left(http.patch),
        headers: headers,
        body: body
    );

    return result;
  }

  WebSocketChannel? connectSeReadingsChannel({
    required String route,
    required StreamController streamController}) {

    WebSocketChannel? channel;
    // initialize channel
    channel = WebSocketChannel.connect(Uri.parse(route));
    // add listener
    try{
      channel = WebSocketChannel.connect(Uri.parse(route));
      channel.stream.listen(
        (data) {
          final Map<String, dynamic> decodedData = jsonDecode(data);
          final SensorNodeSnapshot snapshotObj = SensorNodeSnapshot.fromJSON(decodedData['message']);
          DatabaseHelper.addReadings(snapshotObj);
          DatabaseHelper.readingsLimit(snapshotObj.deviceID);
          // pass to stream controller
          streamController.add(snapshotObj);
          _logs.info(message: 'snapshotObj sent added to snReadingsStreamController -> ${snapshotObj.toString()}');
        }, onError: (err) {
          _logs.warning(message: 'connectSeReadingsChannel() error in stream.listen -> $err');
        }
      );
    } on WebSocketChannelException catch (e) {
      _logs.warning(message: 'connectSeReadingsChannel() called WebSocketChannelException -> $e');
    } on Exception catch (e) {
      _logs.warning(message: 'connectSeReadingsChannel() unhandled unexpected exception raised -> $e');
    }

    // return channel instance
    return channel;
  }

  WebSocketChannel? connectAlertsChannel ({
    required String route,
    required StreamController streamController}) {
    
    WebSocketChannel? channel;
    // initialize channel
    try {
      channel = WebSocketChannel.connect(Uri.parse(route));
      channel.stream.listen(
        (data){
          final Map<String,dynamic> decodedData = jsonDecode(data);
          final SensorNodeSnapshot snapshotObj = SensorNodeSnapshot.fromJSON(decodedData['message']);
          DatabaseHelper.addReadings(snapshotObj);
          DatabaseHelper.readingsLimit(snapshotObj.deviceID);
          // alert object
          final SMAlerts alertObj = SMAlerts.fromJSON(decodedData['message']);
          streamController.add(alertObj);
          _logs.info(message: 'alertObject sent added to alertStreamController -> ${alertObj.toString()}');
        }, onError: (err) {
          _logs.warning(message: 'connectAlertsChannel() error in stream.listen -> $err');
        }
      );
    } on WebSocketChannelException catch (e) {
      _logs.warning(message: 'connectAlertsChannel() called WebSocketChannelException -> $e');
    } on Exception catch (e) {
      _logs.warning(message: 'connectAlertsChannel() unhandled unexpected exception raised -> $e');
    }

    // return channel instance
    return channel;
  }
}
