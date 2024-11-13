import 'dart:convert';

import 'package:jwt_decode/jwt_decode.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smmic/models/auth_models.dart';
import 'package:smmic/models/device_data_models.dart';
import 'package:smmic/utils/datetime_formatting.dart';
import 'package:smmic/utils/logs.dart';

enum Tokens{
  refresh,
  access
}

enum UserFields{
  uid('UID'),
  firstName('first_name'),
  lastName('last_name'),
  province('province'),
  city('city'),
  barangay('barangay'),
  zone('zone'),
  zipCode('zip_code'),
  email('email'),
  password('password'),
  profilePic('profilepic');

  final String key;
  const UserFields(this.key);
}

List<String> sensorNodeKeys = [

];

List<String> _userDataKeys = [
  'UID',
  'first_name',
  'last_name',
  'province',
  'city',
  'barangay',
  'zone',
  'zip_code',
  'email',
  'password',
  'profilepic'
];

///SharedPreferences Utilities for setting and getting data from the SharedPreferences
class SharedPrefsUtils {

  //Dependencies
  final DateTimeFormatting _dateTimeFormatting = DateTimeFormatting();
  final Logs _logs = Logs(tag: 'SharedPrefsUtils()');

  ///Gets `refresh` and `access` tokens from SharedPreferences. Returns both tokens by default
  Future<Map<String, dynamic>> getTokens({
    bool? refresh,
    bool? access,
    SharedPreferences? sharedPrefsInstance}) async {

    Map<String, dynamic> tokens = {};

    SharedPreferences sharedPreferences = sharedPrefsInstance
        ?? await SharedPreferences.getInstance();

    String? refreshToken = sharedPreferences.getString('refresh');
    String? accessToken = sharedPreferences.getString('access');

    if(refresh == null && access == null){
      tokens.addAll({'refresh':refreshToken, 'access':accessToken});
      return tokens;
    }

    if(refresh != null && refresh){
      tokens.addAll({'refresh':refreshToken});
      _logs.info(message: 'getTokens() refreshToken: ${refreshToken.toString().substring(0, 25)}...');
    }

    if(access != null && access){
      tokens.addAll({'access':accessToken});
      _logs.info(message: 'getTokens() accessToken: ${accessToken.toString().substring(0, 25)}...');
    }

    return tokens;
  }

  ///Stores tokens to SharedPreferences.
  ///
  ///Receives a Key:Value map using Tokens enums as keys (Tokens.refresh or Tokens.access)
  Future<void> setTokens({required Map<Tokens, dynamic> tokens}) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (tokens.containsKey(Tokens.refresh) && tokens[Tokens.refresh] != null){
      await sharedPreferences.setString('refresh', tokens[Tokens.refresh]);
    }
    if(tokens.containsKey(Tokens.access) && tokens[Tokens.access] != null){
      await sharedPreferences.setString('access', tokens[Tokens.access]);
    }
    return;
  }

  ///Sets the login timestamp parsed from a refresh token
  Future<void> setLoginFromRefresh({required String refresh}) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Map<String, dynamic> parsed = Jwt.parseJwt(refresh);
    String timestamp = _dateTimeFormatting.fromJWTSeconds(parsed['iat']).toString();
    _logs.info(message: 'setLoginFromRefresh timestamp from refreshToken: $timestamp');
    await sharedPreferences.setString('login', timestamp);
  }

  Future<String?> getLogin() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString('login');
  }

  /// This function clears `access`, `refresh`, and `login` keys from SharedPreferences
  ///
  /// Useful when a forceLogin is required or when the user logs out. Outside of those two scenarios, use with caution.
  Future<void> clearTokens() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    List<String> keys = ['refresh', 'access', 'login'];
    int index = 0;
    while(index < keys.length){
      if(sharedPreferences.containsKey(keys[index])){
        await sharedPreferences.remove(keys[index]);
      }
      index++;
    }
  }

  //TODO: rework how user data is stored to SharedPreferences (key:value pair dapat)
  /// Stores Map of `user_data` to SharedPreferences as `List<String>`
  Future<bool> setUserData({required Map<String,dynamic> userInfo}) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    bool matched = true;
    for(int i = 0; i < _userDataKeys.length; i++){
      if(userInfo.keys.toList()[i] != _userDataKeys[i]){
        matched = false;
      }
    }
    if(!matched){
      throw ('error: User data Map keys provided to SharedPrefsUtils.setUserData did match registered user_data keys');
    }

    bool success = await sharedPreferences.setStringList('user_data', userInfo.keys.map((item) => userInfo[item].toString()).toList());

    return success;
  }

  /// Returns the user data stored from SharedPreferences as a Map.
  ///
  /// Returns a null of the `user_data` from SharedPreferences is empty.
  ///
  /// Returns an 'error' key if the registered `keys` length does not match with the retrieved String List length from SharedPreferences
  Future<Map<String, dynamic>?> getUserData() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (!sharedPreferences.containsKey('user_data')){
      return null;
    }
    if (sharedPreferences.getStringList('user_data') != null){
      List<String> userData = sharedPreferences.getStringList('user_data')!;
      return _userDataMapper(userData);
    }
    throw('An unexpected error has occurred on SharedPrefsUtils.getStringList');
  }

  /// Maps the StringList that `getUserData()` returns
  Map<String, dynamic> _userDataMapper(List<String> userData) {
    if(userData.length != _userDataKeys.length){
      return {'error':'userData and keys length not matched, check userData contents'};
    }
    Map<String, dynamic> userMapped = {};
    for(int i = 0; i < _userDataKeys.length; i++){
      userMapped.addAll({_userDataKeys[i]:userData[i]});
    }
    return userMapped;
  }

  /// Set the sink list into the shared preferences
  Future<bool> setSinkList({required List<Map<String,dynamic>> sinkList}) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    List <String> sinkData = sinkList.map(
            (sink) => SinkNodeKeys.values.map(
                    (key) => (sink[key.key] == List<String>)
                        ? sink[key.key].join(",")
                        : sink[key.key])
                .toList().join(":"))
        .toList();

    bool success = await sharedPreferences.setStringList('sink_data', sinkData);
    return success;
  }

  /// Get the sink list from the shared preferences
  Future<List<Map<String,dynamic>>> getSinkList() async {
    // acquire from shared prefs
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    List<String>? sinkNodeList =  sharedPreferences.getStringList('sink_data');

    // map each item in the sink node string list from shared prefs
    // and insert all into the final sink list
    List<Map<String,dynamic>> finalSinkList = (sinkNodeList == null)
        ? []
        : sinkNodeList.map(
            (sink) {
              Map<String,dynamic> sinkMap = {};
              List<String> sinkValues = sink.split(":");

              for (SinkNodeKeys key in SinkNodeKeys.values) {
                if (key.key == SinkNodeKeys.registeredSensorNodes.key) {
                  sinkMap[key.key] = sinkValues[key.index]
                      .replaceAll(RegExp(r'[\[\]]'), '')
                      .split(',');
                } else {
                  try {
                    sinkMap[key.key] = int.parse(sinkValues[key.index]);
                  } on FormatException catch (e) {
                    sinkMap[key.key] = sinkValues[key.index];
                  }
                }
              }
              return sinkMap;})
        .toList();

    return finalSinkList;
  }

  Future<bool> setSensorList({required List <Map<String,dynamic>> sensorList}) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    List<String> sensorData = sensorList.map(
            (sensor) => SensorNodeKeys.values.map(
                    (key) => sensor[key.key])
                .toList().join(':'))
        .toList();

    bool success = await sharedPreferences.setStringList('sensor_data', sensorData);
    return success;
  }

  Future <List<Map<String,dynamic>>> getSensorList() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    List<String>? sensorNodeList = sharedPreferences.getStringList('sensor_data');

    List<Map<String, dynamic>> sensorNodeListMap = (sensorNodeList == null)
        ? []
        : sensorNodeList.map(
            (sensor){
              Map<String, dynamic> sensorMap = {};
              List<String> sensorValues = sensor.split(':');
              for (SensorNodeKeys key in SensorNodeKeys.values) {
                try {
                  sensorMap[key.key] = int.parse(sensorValues[key.index]);
                } on FormatException catch (e) {
                  sensorMap[key.key] = sensorValues[key.index];
                }
              }
              return sensorMap;
            })
        .toList();

    return sensorNodeListMap;
  }

  Future<bool> setAlertsData({required List<Map<String, dynamic>> alertsList}) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();


    _logs.info(message:"setAlertsData alertsList: ${alertsList.toString()}");

    List<String> alertsData = alertsList.map((alert){
      return alert.keys.map((key){
        var value = alert[key];
        return value is List<String> ? value.join(",") : value.toString();
      }).toList().join(";");
    }).toList();

    _logs.info(message: "alertsData instance: $alertsData");

    bool success = await sharedPreferences.setStringList("alerts_data", alertsData);

    return success;
  }



  Future<List<Map<String,dynamic>>?> getAlertsData() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    List<String>? alertsList = sharedPreferences.getStringList('alerts_data');
    List<String> keys = ['device_id','timestamp','alerts','data'];

    List<Map<String,dynamic>> alertsList_map = alertsList == null ? [] : alertsList.map((alert){
      Map<String,dynamic> map = {};
      List<String> values = alert.split(";");

      for(int i =0; i < keys.length; i ++){
        map[keys[i]] = values[i];
      }
      return map;
    }).toList();

    _logs.info(message: "alertsListMap : $alertsList_map");

    return alertsList_map;
  }

}