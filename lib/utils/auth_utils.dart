import 'dart:convert';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:smmic/constants/api.dart';
import 'package:smmic/providers/auth_provider.dart'; //Token status
import 'package:http/http.dart' as http;
import 'package:smmic/utils/datetime_formatting.dart';
import 'package:smmic/utils/shared_prefs.dart';

///Authentication utilities, contains all reusable functions for authentication purposes, mainly token handling (`verify token`, `refresh access token`)
class AuthUtils {
  final ApiRoutes _apiRoutes = ApiRoutes();
  final SharedPrefsUtils _sharedPrefsUtils = SharedPrefsUtils();
  final DateTimeFormatting _dateTimeFormatting = DateTimeFormatting();

  ///Parses a JWT token and returns a map with keys: `token`, `user_id`, `token_id`, `created`, `expires`. Will return a null value of the token is null.
  Map<String, dynamic>? parseToken({String? token}){
    Map<String, dynamic> mapped = {};
    if (token == null || token == ''){
      return null;
    }
    Map<String, dynamic> parsed = Jwt.parseJwt(token);
    mapped.addAll({
      'token': token,
      'user_id': parsed['user_id'],
      'token_id': parsed['jti'],
      'created': parsed['iat'],
      'expires': parsed['exp']
    });
    return mapped;
  }

  ///Verifies token validity from api. Returns `TokenStatus` enums, useful for validating access from and to database
  Future<TokenStatus> verifyToken({required String? token, bool refresh = false}) async {
    if (token == null){
      return refresh ? TokenStatus.forceLogin : TokenStatus.invalid;
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

  ///Refreshes access token and stores the new token in SharedPreferences. Returns null if `refresh` is invalid, expired, or does not exist.
  ///
  ///Handle null value using forceLogin or other error handling functions to avoid the funny
  Future<String?> refreshAccessToken({required String refresh, bool setAccess = false}) async {
    try{
      final response = await http.post(Uri.parse(_apiRoutes.refreshToken), body: {'refresh': refresh});
      if(response.statusCode == 400 || response.statusCode == 401) {
        //TODO: refactor error handling
        throw Exception('error on AuthUtils.refresh: check `refresh` header or refreshToken validity');
      }
      if(response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        await _sharedPrefsUtils.setTokens(tokens: {Tokens.access: jsonData['access']});
        return jsonData['access'];
      }
      return null;
    } catch(e) {
      throw Exception(e);
    }
  }
}