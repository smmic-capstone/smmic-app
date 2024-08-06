import 'dart:math';

import 'package:jwt_decode/jwt_decode.dart';
import 'package:smmic/models/auth_models.dart';
import 'package:flutter/material.dart';
import 'package:smmic/utils/auth_utils.dart';
import 'package:smmic/utils/datetime_formatting.dart';
import 'package:smmic/utils/global_navigator.dart';
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

  //Dependencies
  final AuthUtils _authUtils = AuthUtils();
  final SharedPrefsUtils _sharedPrefsUtils = SharedPrefsUtils();
  final GlobalNavigator _globalNavigator = locator<GlobalNavigator>();

  ///Returns the access data
  UserAccess? _accessData;
  UserAccess? get accessData => _accessData;

  ///Returns the access status
  TokenStatus? _accessStatus;
  TokenStatus? get accessStatus => _accessStatus;

  Future<void> init() async {
    String? login = await _sharedPrefsUtils.getLogin();
    if(login == null) return;
    Map<String, dynamic> tokens = await _sharedPrefsUtils.getTokens();
    TokenStatus refreshStatus = await _authUtils.verifyToken(token: tokens['refresh'], refresh: true);
    if(refreshStatus == TokenStatus.forceLogin){
      _accessData = null;
      _accessStatus = TokenStatus.forceLogin;
      _globalNavigator.forceLoginDialog();
      notifyListeners();
      return;
    }
    TokenStatus accessStatus = await _authUtils.verifyToken(token: tokens['access']);
    if (accessStatus != TokenStatus.valid) {
      String? newAccess = await _authUtils.refreshAccessToken(refresh: tokens['refresh']);
      if (newAccess != null) {
        Map<String, dynamic>? newMapped = _authUtils.parseToken(token: newAccess);
        _accessData = UserAccess.fromJSON(newMapped!);
        _accessStatus = await _authUtils.verifyToken(token: newAccess);
      } else {
        _accessData = null;
        _accessStatus = TokenStatus.invalid;
      }
    } else {
      Map<String, dynamic>? parsedToken = _authUtils.parseToken(token: tokens['access']);
      _accessData = UserAccess.fromJSON(parsedToken!);
      _accessStatus = accessStatus;
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