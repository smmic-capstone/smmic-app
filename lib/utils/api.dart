import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:smmic/models/device_data_models.dart';
import 'package:smmic/providers/devices_provider.dart';
import 'package:smmic/sqlitedb/db.dart';
import 'package:smmic/utils/logs.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ApiRequest {
  final Logs _logs = Logs(tag: 'ApiRequest()');

  /// Get request for api, returns a the response status code and the body if available
  Future<dynamic> get({required String route, Map<String, String>? headers}) async {
    try{
      _logs.info(message: 'get() $route, headers: ${headers ?? 'none'}');
      final response = await http.get(Uri.parse(route), headers: headers);
      if(response.statusCode == 500){
        _logs.error(message: 'get() $route, returned with error ${response.statusCode}');
        return {'error' : response.statusCode, 'data' : {'err':'internal server error (code 500)'}};
      } else if (response.statusCode == 400) {
        _logs.warning(message: 'post() $route, returned with error ${response.statusCode}');
        return {'error' : response.statusCode, 'data' : jsonDecode(response.body)};
      } else if (response.statusCode == 401) {
        _logs.warning(message: 'post() $route, returned with error ${response.statusCode}');
        return {'error' : response.statusCode, 'data' : jsonDecode(response.body)};
      }
      if(response.statusCode == 200){
        _logs.success(message: 'post() $route, returned with data ${response.statusCode}');
        return {'code' : response.statusCode, 'data' : jsonDecode(response.body)};
      }
    } catch(e) {
      return {'error' : e};
    }
    return {'error' : 'unhandled unexpected get() error'};
  }

  Future<Map<String, dynamic>> post({required String route, Map<String, String>? headers, Object? body}) async {
    _logs.info(message: 'post() -> route: $route, headers: $headers, body: $body');
    http.Response? response;
    try{
      response = await http.post(Uri.parse(route), headers: headers, body: body);
      if(response.statusCode == 500){
        _logs.error(message: 'post() $route, returned with error ${response.statusCode}');
        return {'error' : response.statusCode, 'data' : {'err':'internal server error (code 500)'}};
      } else if (response.statusCode == 400) {
        _logs.warning(message: 'post() $route, returned with error ${response.statusCode}');
        return {'error' : response.statusCode, 'data' : jsonDecode(response.body)};
      } else if (response.statusCode == 401) {
        _logs.warning(message: 'post() $route, returned with error ${response.statusCode}');
        return {'error' : response.statusCode, 'data' : jsonDecode(response.body)};
      }
      if(response.statusCode == 200){
        _logs.success(message: 'post() $route, returned with data ${response.statusCode}');
        return {'success' : response.statusCode, 'data': jsonDecode(response.body)};
      }
    } catch(e) {
      throw Exception(e);
    }
    _logs.warning(message: 'post() unhandled unexpected post() error (statusCode: ${response.statusCode}, body: ${response.body})');
    return {'error' : 'unhandled unexpected post() error', 'status_code' : response.statusCode, 'body': response.body};
  }

  Future<Map<String, dynamic>> put({required String route, Map<String, String>? headers, Object? body}) async {
    try{
      _logs.info(message: 'put() $route, headers: ${headers ?? 'none'}, body: ${body ?? 'none'}');
      final response = await http.put(Uri.parse(route), headers: headers, body: body);
      if(response.statusCode == 500){
        _logs.error(message: 'put() $route, returned with error ${response.statusCode}');
        return {'error' : response.statusCode, 'data' : {'err':'internal server error (code 500)'}};
      } else if (response.statusCode == 400) {
        _logs.warning(message: 'put() $route, returned with error ${response.statusCode}');
        return {'error' : response.statusCode, 'data' : jsonDecode(response.body)};
      } else if (response.statusCode == 401) {
        _logs.warning(message: 'put() $route, returned with error ${response.statusCode}');
        return {'error' : response.statusCode, 'data' : jsonDecode(response.body)};
      }
      if(response.statusCode == 200){
        _logs.success(message: 'put() $route, returned with data ${response.statusCode}');
        return {'success' : response.statusCode, 'data': jsonDecode(response.body)};
      }
    } catch(e) {
      throw Exception(e);
    }
    return {'error' : 'unhandled unexpected put() error'};
  }

  Future<Map<String, dynamic>> patch({required String route, Map<String, String>? headers, Object? body}) async {
    try{
      _logs.info(message: 'patch() $route, headers: ${headers ?? 'none'}, body: ${body ?? 'none'}');
      final response = await http.patch(Uri.parse(route), headers: headers, body: body);
      if(response.statusCode == 500){
        _logs.error(message: 'patch() $route, returned with error ${response.statusCode}');
        return {'error' : response.statusCode, 'data' : {'err':'internal server error (code 500)'}};
      } else if (response.statusCode == 400) {
        _logs.warning(message: 'patch() $route, returned with error ${response.statusCode}');
        return {'error' : response.statusCode, 'data' : jsonDecode(response.body)};
      } else if (response.statusCode == 401) {
        _logs.warning(message: 'patch() $route, returned with error ${response.statusCode}');
        return {'error' : response.statusCode, 'data' : jsonDecode(response.body)};
      }
      if(response.statusCode == 200){
        _logs.success(message: 'patch() $route, returned with data ${response.statusCode}');
        return {'success' : response.statusCode, 'data': jsonDecode(response.body)};
      }
    } catch(e) {
      throw Exception(e);
    }
    return {'error' : 'unhandled unexpected patch() error'};
  }

  void channelConnect({required String route, Map<String,String>? headers, Object? body, required StreamController controller}) {

    try{
      _logs.info(message: "channelConnect initializing");
      final channel =  WebSocketChannel.connect(Uri.parse(route));
      _logs.info(message: 'stream response: ${channel.stream}');
      channel.stream.listen((data) async {
        _logs.info(message: 'stream data type: ${data.runtimeType}');
        final Map<String,dynamic> decodedData = jsonDecode(data);
        _logs.info(message: 'decoded data: $decodedData');
        final Map<String,dynamic> messageData = decodedData['message'];
        _logs.info(message: 'message data: $messageData');
        final SensorNodeSnapshot mappedData = SensorNodeSnapshot.fromJSON(messageData);
        _logs.info(message: 'Mapped Data: $mappedData');
        _logs.info(message: 'Adding Mapped Data to SQFLITE');
        DatabaseHelper.addReadings(mappedData);
        controller.add(mappedData);
        await Future<void>.delayed(const Duration(seconds:4));
      });
    } catch(e) {
      _logs.error(message: 'Failed to connect to websocket');
      _logs.error(message: '$e');
      throw Exception(e);
    }
    return;
  }

}