import 'dart:convert';
import 'package:smmic/constants/api.dart';
import 'package:http/http.dart' as http;
import 'package:smmic/providers/auth_provider.dart';
import 'package:smmic/utils/auth_utils.dart';
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


  //TODO: refactor when api is up
  List<String> getSensorNodes(String sinkNodeID) {
    return mockSensorNodesList[sinkNodeID] ?? [];
  }

  List<String> getSinkNodes() {
    return mockSinkNodesList;
  }

  Future<Map<String, dynamic>?> getUserInfo({required String token}) async {
    try{
      String? accessToken;
      TokenStatus accessStatus = await _authUtils.verifyToken(token: token);
      if(accessStatus != TokenStatus.valid){
        Map<String,dynamic> refresh = await _sharedPrefsUtils.getTokens(refresh: true);
        accessToken = await _authUtils.refreshAccessToken(refresh: refresh['refresh']);
        await _authProvider.setAccess(access: accessToken!);
      }
      final response = await http.get(
          Uri.parse(_apiRoutes.getUserData),
        headers: {"Authorization":"Bearer ${accessToken ?? token}"}
      );
      // if error
      if (response.statusCode == 500 || response.statusCode == 401 || response.statusCode == 400) {
        return {'error':response.statusCode};
      }
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch(error) {
      return {'error': error};
    }
    return null;
  }



}