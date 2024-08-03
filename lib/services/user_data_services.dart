import 'dart:convert';
import 'dart:math';

import 'package:provider/provider.dart';
import 'package:smmic/constants/api.dart';
import 'package:smmic/providers/user_data_providers.dart';
import 'package:http/http.dart' as http;

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
  final AuthProvider _authProvider = AuthProvider();

  //TODO: refactor when api is up
  List<String> getSensorNodes(String sinkNodeID) {
    return mockSensorNodesList[sinkNodeID] ?? [];
  }

  List<String> getSinkNodes() {
    return mockSinkNodesList;
  }

  Future<Map<String, dynamic>?> getUserInfo({required String token}) async {

    try{
      final response = await http.get(
          Uri.parse(_apiRoutes.getUserURL),
        headers: {"Authorization":"Bearer $token"}
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