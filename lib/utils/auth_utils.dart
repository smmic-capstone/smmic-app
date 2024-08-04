import 'dart:convert';

import 'package:jwt_decode/jwt_decode.dart';
import 'package:smmic/constants/api.dart';
import 'package:smmic/providers/auth_provider.dart'; //Token status
import 'package:http/http.dart' as http;
import 'package:smmic/utils/datetime_formatting.dart';
import 'package:smmic/utils/shared_prefs.dart';

///Authentication utilities, contains all reusable functions for authentication purposes, mainly token handling (`verify token`, `initialize access token object`, `refresh access token`)
class AuthUtils {
  final ApiRoutes _apiRoutes = ApiRoutes();
  final SharedPrefsUtils _sharedPrefsUtils = SharedPrefsUtils();
  final DateTimeFormatting _dateTimeFormatting = DateTimeFormatting();

  ///Verifies token validity from api. Returns `TokenStatus` enums, useful for validating access from and to database
  Future<TokenStatus> verifyToken({required String? token, required bool refresh}) async {
    if (token == null){
      return refresh ? TokenStatus.invalid : TokenStatus.forceLogin;
    }
    Map<String, dynamic> parsed = Jwt.parseJwt(token);
    DateTime expires = _dateTimeFormatting.fromJWTSeconds(parsed['exp']);
    if (expires.compareTo(DateTime.now()) < 0) {
      return refresh ? TokenStatus.forceLogin : TokenStatus.expired;
    }
    try{
      final response = await http.post(Uri.parse(_apiRoutes.verifyToken), body:{'token': token});
      if (response.statusCode == 400 || response.statusCode == 401) {
        return refresh ? TokenStatus.forceLogin : TokenStatus.invalid;
      }
      if (response.statusCode == 200) {
        return TokenStatus.valid;
      }
    } catch(e) {
      Exception(e);
    }
    return TokenStatus.unverified;
  }

  ///Returns true if forced login is required
  Future<bool> forceLoginCheck({required String?  refresh}) async {
    TokenStatus refreshStatus = await verifyToken(token: refresh, refresh: true);
    return refreshStatus == TokenStatus.forceLogin;
  }

  ///Refreshes access token. If `refresh` itself is invalid, expired, or does not exist `refresh` will force a re-login
  Future<String?> refresh({required String refresh}) async {
    try{
      final response = await http.post(Uri.parse(_apiRoutes.refreshToken), body: {'refresh':refresh});
      if(response.statusCode == 400 || response.statusCode == 401) {
        throw Exception('error on AuthUtils.refresh: check `refresh` header or refreshToken validity');
      }
      if(response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        _sharedPrefsUtils.setAccess(jsonData['access']);
      }
      return null;
    } catch(e) {
      throw Exception(e);
    }
  }

  ///Initializes the access object from the access data stored in SharedPrefs. Calls 'refresh' for the access if access is expired, returns a 'status' = `TokenStatus.forceLogin` if refresh is null
  Future<Map<String, dynamic>> initAccess() async {
      String? accessToken = await _sharedPrefsUtils.getAccess();
      String? refreshToken = await _sharedPrefsUtils.getRefresh();
      bool forceLogin = await forceLoginCheck(refresh: refreshToken);
      if (forceLogin){
        return {'token':null, 'status':TokenStatus.forceLogin};
      }
      TokenStatus accessStatus = await verifyToken(token: accessToken, refresh: false);
      if (accessStatus != TokenStatus.valid){
        String? newAccess = await refresh(refresh: refreshToken!);
        TokenStatus newAccessStatus = await verifyToken(token: newAccess, refresh: false);
        return {'token':newAccess, 'status': newAccessStatus};
      }
      return {'token':accessToken, 'status':accessStatus};
  }

}