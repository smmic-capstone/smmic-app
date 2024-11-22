import 'dart:convert';

import 'package:smmic/constants/api.dart';
import 'package:smmic/utils/api.dart';
import 'package:smmic/utils/logs.dart';
import 'package:http/http.dart' as http;


class PusherAuth{
  /*final ApiRequest _apiRequest = ApiRequest();*/
  final ApiRoutes _apiRoutes = ApiRoutes();
  final Logs _logs = Logs(tag: "Pusher Authentication");

  Future <dynamic> authorize ({
    required String accessToken,
    required String socketID,
    required String channelName}) async {
    _logs.warning(message: "PusherAuth Running");
    _logs.warning(message: "PusherAuth: $accessToken, $socketID, $channelName");

    final pusherAuthResponse = await http.post(Uri.parse(_apiRoutes.pusherAuth),
      headers: {
        'Authorization' : 'Bearer $accessToken',
        'Content-Type' : 'application/json',
      },
      body: jsonEncode({
        'socket_id' : socketID,
        'channel_name' : channelName
      }),
    );

    if(pusherAuthResponse.statusCode == 200){
      final jsonData = jsonDecode(pusherAuthResponse.body);
      _logs.warning(message: jsonData['auth']);
    }



    /*final pusherAuthResponse = await _apiRequest.post(
        route: _apiRoutes.pusherAuth,
    headers: {
          'Authorization' : 'Bearer $accessToken'
    },
    body: {
          'socket_id' : socketID,
          'channel_name' : channelName
    });*/

    if(pusherAuthResponse == null){
      _logs.warning(message: "Pusher Auth not successful");
    }

    _logs.warning(message: "pusher token : $pusherAuthResponse");

    return pusherAuthResponse;
  }
}