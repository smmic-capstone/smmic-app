import 'dart:convert';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:smmic/constants/api.dart';
import 'package:http/http.dart' as http;
import 'package:smmic/providers/auth_provider.dart';
import 'package:smmic/utils/auth_utils.dart';
import 'package:smmic/utils/datetime_formatting.dart';
import 'package:smmic/utils/shared_prefs.dart';

///Authentication services, contains all major authentication functions (`login`, `logout`, `create account`, `delete account`, `update account`)
class AuthService {

  final ApiRoutes _apiRoutes = ApiRoutes();
  final AuthProvider _authProvider = AuthProvider();
  final AuthUtils _authUtils = AuthUtils();
  final SharedPrefsUtils _sharedPrefsUtils = SharedPrefsUtils();
  final DateTimeFormatting _dateTimeFormatting = DateTimeFormatting();

  Future<String>? login({required String email, required String password}) async {
    try{
      final response = await http.post(Uri.parse(_apiRoutes.login), body: {
        'email' : email,
        'password' : password
      });
      // 500 error code
      if (response.statusCode == 500){
        return response.statusCode.toString();
      }

      // if wrong credentials
      if(response.statusCode == 401){
        return response.statusCode.toString();
      }

      // successful
      if (response.statusCode == 200){
        final jsonData = jsonDecode(response.body);
        await _sharedPrefsUtils.setAccess(jsonData['access']);
        await _sharedPrefsUtils.setRefresh(jsonData['refresh']);
        return jsonData['access'];
      }
    } catch(error) {
      //TODO: define error handling
    }
    throw Exception('gg');
  }

  // Future<int?> logout({required String userID}) async {
  //   //TODO: implement logout
  // }

}