import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smmic/utils/logs.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import '../constants/api.dart';
import '../utils/api.dart';



// used to pass messages from event handler to the UI
final _messageStreamController = BehaviorSubject<RemoteMessage>();

class FcmProvider extends ChangeNotifier {
  final Logs _logs = Logs(tag: 'FCM Provider');
  final ApiRoutes _apiRoutes = ApiRoutes();
  final ApiRequest _apiRequest = ApiRequest();



  Future<void> init() async {
    _logs.info2(message: "init() executing");

    ///FCM Request User Permissions for notifications
    final messaging = FirebaseMessaging.instance;

    final settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (kDebugMode) {
      print('Permission granted: ${settings.authorizationStatus}');
    }


    if(settings.authorizationStatus == AuthorizationStatus.authorized){
      _logs.info(message: "User is authorized");
      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

      String? accessToken = sharedPreferences.getString('access');
      String? deviceToken = await messaging.getToken();
      String? deviceType;

      if(Platform.isAndroid){
        deviceType = "android";
      }else if(Platform.isIOS){
        deviceType = "ios";
      }else{
        return;
      }

      if(accessToken!.isNotEmpty && deviceToken!.isNotEmpty && deviceType.isNotEmpty){

        try{
          _apiRequest.post(route: _apiRoutes.deviceNotifications,
              headers:{"Authorization" : "Bearer $accessToken"},
              body: {
                "registration_id" : deviceToken,
                "type" : deviceType
              });
        }catch(error){
          _logs.error(message: "error getting in fcm_provider: $error");
        }
      }else{
        _logs.error(message: "accessToken = $accessToken, deviceToken: $deviceToken, deviceType: $deviceType");
      }
    }

    ///Registration token for the server to use to send messages
    // It requests a registration token for sending messages to users from your App server or other trusted server environment.





    ///Foreground message handling
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('Handling a foreground message: ${message.messageId}');
        print('Message data: ${message.data}');
        print('Message notification: ${message.notification?.title}');
        print('Message notification: ${message.notification?.body}');
      }

      _messageStreamController.sink.add(message);
    });


    ///For Future Reference the Stream Listener
    //String _lastMessage = "";
    //_messageStreamController.listen((message) {
    //      setState(() {
    //        if (message.notification != null) {
    //          _lastMessage = 'Received a notification message:'
    //              '\nTitle=${message.notification?.title},'
    //              '\nBody=${message.notification?.body},'
    //              '\nData=${message.data}';
    //        } else {
    //          _lastMessage = 'Received a data message: ${message.data}';
    //        }
    //      });
    //    });



  }
}