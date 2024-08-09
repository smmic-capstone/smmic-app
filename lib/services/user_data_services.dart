import 'dart:convert';
import 'package:smmic/constants/api.dart';
import 'package:http/http.dart' as http;
import 'package:smmic/providers/auth_provider.dart';
import 'package:smmic/utils/api.dart';
import 'package:smmic/utils/auth_utils.dart';
import 'package:smmic/utils/logs.dart';
import 'package:smmic/utils/shared_prefs.dart';

List<String> mockSinkNodesList = [
  'SIqokAO1BQBHyJVK',
  'SIqokAO1BQbgyJ2K'
];

Map<String, List<String>> mockSensorNodesList = {
  'SIqokAO1BQBHyJVK' : ['SEx0e9bmweebii5y', 'SEqokAO1BQBHyJVK'],
  'SIqokAO1BQbgyJ2K' : []
};

class UserDataServices {
  final ApiRoutes _apiRoutes = ApiRoutes();
  final AuthUtils _authUtils = AuthUtils();
  final AuthProvider _authProvider = AuthProvider();
  final SharedPrefsUtils _sharedPrefsUtils = SharedPrefsUtils();
  final ApiRequest _apiRequest = ApiRequest();

  //TODO: refactor when api is up
  List<String> getSensorNodes(String sinkNodeID) {
    return mockSensorNodesList[sinkNodeID] ?? [];
  }

  List<String> getSinkNodes() {
    return mockSinkNodesList;
  }

  /// Returns a map of the user data, will return a map with an `error` String key if an error is returned from the request
  Future<Map<String, dynamic>?> getUserInfo({required String token}) async {
    String? accessToken;
    TokenStatus accessStatus = await _authUtils.verifyToken(token: token);

    // check access token validity, executes AuthUtils().refreshAccessToken() if access is invalid or expired
    if(accessStatus != TokenStatus.valid){
      Map<String,dynamic> refresh = await _sharedPrefsUtils.getTokens(refresh: true);
      accessToken = await _authUtils.refreshAccessToken(refresh: refresh['refresh']);
      await _authProvider.setAccess(access: accessToken!);
    }

    final Map<String, dynamic> data = await _apiRequest.get(route: _apiRoutes.getUserData, headers: {'Authorization':'Bearer $token'});

    // TODO: HANDLE ERROR SCENARIO
    if(data.containsKey('error')){
      return data;
    }

    return data;
  }

}