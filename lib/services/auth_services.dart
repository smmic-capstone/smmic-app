import 'dart:convert';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:smmic/constants/api.dart';
import 'package:http/http.dart' as http;
import 'package:smmic/providers/auth_provider.dart';
import 'package:smmic/providers/user_data_provider.dart';
import 'package:smmic/utils/auth_utils.dart';
import 'package:smmic/utils/datetime_formatting.dart';
import 'package:smmic/utils/logs.dart';
import 'package:smmic/utils/shared_prefs.dart';

///Authentication services, contains all major authentication functions (`login`, `logout`, `create account`, `delete account`, `update account`)
class AuthService {

  final ApiRoutes _apiRoutes = ApiRoutes();
  final UserDataProvider _userDataProvider = UserDataProvider();
  final AuthUtils _authUtils = AuthUtils();
  final SharedPrefsUtils _sharedPrefsUtils = SharedPrefsUtils();
  final DateTimeFormatting _dateTimeFormatting = DateTimeFormatting();

  Future<Map<String, dynamic>>? login({required String email, required String password}) async {
    try{
      final response = await http.post(Uri.parse(_apiRoutes.login), body: {
        'email' : email,
        'password' : password
      });
      // 500 error code
      if (response.statusCode == 500){
        return {'error_code': response.statusCode.toString()};
      }
      // if wrong credentials
      if(response.statusCode == 401){
        return {'error_code': response.statusCode.toString()};
      }
      // successful
      if (response.statusCode == 200){
        final jsonData = jsonDecode(response.body);
        TokenStatus verifyAccess = await _authUtils.verifyToken(token: jsonData['access'], refresh: false);
        TokenStatus verifyRefresh = await _authUtils.verifyToken(token: jsonData['refresh'], refresh: true);
        if (verifyRefresh != TokenStatus.valid) {
          return {'refresh_err':'refresh_token_invalid'};
        }
        String? newAccess;
        if (verifyAccess != TokenStatus.valid) {
          newAccess = await _authUtils.refreshAccessToken(refresh: jsonData['refresh']);
          verifyAccess = await _authUtils.verifyToken(token: newAccess);
        }
        if (verifyAccess == TokenStatus.valid) {
          await _sharedPrefsUtils.setTokens(tokens: {Tokens.refresh: jsonData['refresh'], Tokens.access: newAccess ?? jsonData['access']});
          await _sharedPrefsUtils.setLoginFromRefresh(refresh: jsonData['refresh']);
          newAccess != null ? _userDataProvider.init() : (); //dont execute UserData.init() when newAccess is null
          return {'access' : jsonData['access'], 'status' : verifyAccess};
        }
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