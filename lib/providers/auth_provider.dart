import 'dart:math';

import 'package:jwt_decode/jwt_decode.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smmic/models/auth_models.dart';
import 'package:flutter/material.dart';
import 'package:smmic/utils/auth_utils.dart';
import 'package:smmic/utils/datetime_formatting.dart';
import 'package:smmic/utils/global_navigator.dart';
import 'package:smmic/utils/logs.dart';
import 'package:smmic/utils/shared_prefs.dart';

///Specifies current status of the token
enum TokenStatus {
  pending, /// Pending verification from API
  valid, /// Validated from API
  invalid, /// Invalid token
  expired, /// Expired token
  unverified, /// Cannot verify
  forceLogin /// Force re log in
}

///Authentication Provider
class AuthProvider extends ChangeNotifier {

  // utils
  final AuthUtils _authUtils = AuthUtils();
  final SharedPrefsUtils _sharedPrefsUtils = SharedPrefsUtils();
  final GlobalNavigator _globalNavigator = locator<GlobalNavigator>();
  final Logs _logs = Logs(tag: 'AuthProvider()');

  ///Returns the access data
  UserAccess? _accessData;
  UserAccess? get accessData => _accessData;

  ///Returns the access status
  TokenStatus? _accessStatus;
  TokenStatus? get accessStatus => _accessStatus;

  /// Initializes AuthProvider() using tokens from the SharedPreferences, performs verification on tokens
  Future<void> init() async {
    _logs.info2(message: 'init() executing');
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    //String? login = await _sharedPrefsUtils.getLogin();
    if(!sharedPreferences.containsKey('login')){
      _logs.info(message: 'no login key found, exiting');
      return;
    }
    Map<String, dynamic> tokens = await _sharedPrefsUtils.getTokens();

    //refresh token status check
    _logs.info(message: 'AuthProvider() verifying refreshToken');
    TokenStatus refreshStatus = await _authUtils.verifyToken(token: tokens['refresh'], refresh: true);

    //if refresh status check fails, verifyToken will return a TokenStatus.forceLogin and the forceLoginDialog is executed
    if(refreshStatus == TokenStatus.forceLogin){
      _accessData = null;
      _accessStatus = TokenStatus.forceLogin;
      _globalNavigator.forceLoginDialog();
      notifyListeners();
      _logs.warning(message: 'forceLoginDialog() executed on .init()');
      return;
    }

    //access token status check
    _logs.info(message: 'AuthProvider() verifying accessToken');
    TokenStatus accessStatus = await _authUtils.verifyToken(token: tokens['access']);
    //if access status valid, assign values to _accessData, _accessStatus
    if(accessStatus == TokenStatus.valid){
      _logs.success(message: 'init() executed without errors or warning');
      Map<String, dynamic>? parsedToken = _authUtils.parseToken(token: tokens['access']);
      _accessData = UserAccess.fromJSON(parsedToken!);
      _accessStatus = accessStatus;
    } else {
      _logs.warning(message: 'access token from SharedPreferences failed AuthUtils.verifyToken() check, executing AuthUtils.refreshAccessToken()...');
      String? newAccess = await _authUtils.refreshAccessToken(refresh: tokens['refresh']);
      if (newAccess != null) {
        Map<String, dynamic>? newMapped = _authUtils.parseToken(token: newAccess);
        _accessData = UserAccess.fromJSON(newMapped!);
        _accessStatus = await _authUtils.verifyToken(token: newAccess);
        _logs.info(message: 'access token refreshed, .init() done');
      } else {
        _accessData = null;
        //TODO: handle scenario: invalid token
        _accessStatus = TokenStatus.invalid;
        _logs.warning(message: 'new access token invalid or null');
      }
    }

    notifyListeners();
    return;
  }

  /// Sets new access data for AuthProvider. If accessStatus is not provided, will verify token using AuthUtils.verifyToken
  Future<void> setAccess({required String access, TokenStatus? accessStatus}) async {
    Map<String, dynamic> parsedToken = _authUtils.parseToken(token: access)!;
    if (_checkSessionInstance(parsedToken) != null) {
      return;
    } else {
      _accessData = UserAccess.fromJSON(_authUtils.parseToken(token: access)!);
      _accessStatus = accessStatus ?? await _authUtils.verifyToken(token: access);
    }
    notifyListeners();
  }

  UserAccess? _checkSessionInstance(Map<String, dynamic> parsedToken) {
    if (_accessData == null) {
      return null;
    }
    if (_accessData!.tokenIdentifier == parsedToken['token_id']) {
      return _accessData;
    }
    DateTime expires = DateTimeFormatting().fromJWTSeconds(parsedToken['expires']);
    if (_accessData!.expires.isAfter(expires)) {
      return _accessData;
    }
    return null;
  }

}