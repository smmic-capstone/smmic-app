import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smmic/constants/api.dart';
import 'package:smmic/pages/newlogin.dart';
import 'package:smmic/providers/auth_provider.dart'; //Token status
import 'package:http/http.dart' as http;
import 'package:smmic/utils/api.dart';
import 'package:smmic/utils/datetime_formatting.dart';
import 'package:smmic/utils/logs.dart';
import 'package:smmic/utils/shared_prefs.dart';

///Authentication utilities, contains all reusable functions for authentication purposes, mainly token handling (`verify token`, `refresh access token`)
class AuthUtils {
  final ApiRoutes _apiRoutes = ApiRoutes();
  final SharedPrefsUtils _sharedPrefsUtils = SharedPrefsUtils();
  final DateTimeFormatting _dateTimeFormatting = DateTimeFormatting();
  final ApiRequest _apiRequest = ApiRequest();
  final Logs _logs = Logs(tag: 'Auth Utils');

  ///Parses a JWT token and returns a map with keys: `token`, `user_id`, `token_id`, `created`, `expires`. Will return a null value of the token is null.
  Map<String, dynamic>? parseToken({
    String? token}){

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

    TokenStatus finalStatus = TokenStatus.unverified;
    // if provided token is null
    // return forceLogin if refresh token
    // else return invalid
    if (token == null){
      return TokenStatus.invalid;
    }

    // check if token is expired
    Map<String, dynamic> parsed = Jwt.parseJwt(token);
    DateTime expires = _dateTimeFormatting.fromJWTSeconds(parsed['exp']);
    if (expires.compareTo(DateTime.now()) < 0) {
      return TokenStatus.expired;
    }

    final Map<String, dynamic> data = await _apiRequest.post(
        route: _apiRoutes.verifyToken,
        body: {'token': token}
    );

    switch (data['status_code']) {
      case 200:
        finalStatus = TokenStatus.valid;
        break;
      case 400:
        finalStatus = TokenStatus.invalid;
        break;
      case 500:
        finalStatus = TokenStatus.unverified;
        break;
      case 0:
        finalStatus = TokenStatus.unverified;
        break;
      default:
        finalStatus = TokenStatus.unverified;
        break;
    }

    return finalStatus;
  }

  ///Refreshes access token and stores the new token in SharedPreferences. Returns null if `refresh` is invalid, expired, or does not exist.
  ///
  ///Handle null value using forceLogin or other error handling functions to avoid the funny
  Future<String?> refreshAccessToken({required String refresh, bool setAccess = false}) async {
    Map<String, dynamic> res = await _apiRequest.post(
        route: _apiRoutes.refreshToken,
        body: {'refresh' : refresh}
    );

    // TODO: handle error
    if (res.containsKey('error')) {
      throw Exception(res);
    }

    Map<String, dynamic> body = res['data'];
    await _sharedPrefsUtils.setTokens(
        tokens: {
          Tokens.access: body['access'],
          Tokens.refresh: body['refresh']
        }
    );
    return body['access'];
  }

  Future<void> logoutUser(BuildContext context) async {
    SharedPreferences _sharedPreferences = await SharedPreferences.getInstance();

    String? refreshToken = _sharedPreferences.getString('refresh');

    final logoutResponse = await _apiRequest.post(
        route: _apiRoutes.logout,
        body: {
          'refresh_token' : refreshToken
        });

    if (logoutResponse['status_code'] == 205 && context.mounted){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage() ));
    }
  }

  Future<String?> getRefreshToken() async {
    SharedPreferences _sharedPreferences = await SharedPreferences.getInstance();

    String? refreshToken = _sharedPreferences.getString('refresh');

    return refreshToken;
  }
}