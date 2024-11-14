import 'dart:math';

import 'package:jwt_decode/jwt_decode.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smmic/models/auth_models.dart';
import 'package:flutter/material.dart';
import 'package:smmic/models/user_data_model.dart';
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
}

///Authentication Provider
class AuthProvider extends ChangeNotifier {

  // utils
  final AuthUtils _authUtils = AuthUtils();
  final SharedPrefsUtils _sharedPrefsUtils = SharedPrefsUtils();
  final GlobalNavigator _globalNavigator = locator<GlobalNavigator>();
  final Logs _logs = Logs(tag: 'AuthProvider()');

  ///Returns the access token data as a `UserAccess` object
  UserAccess? _accessData;
  UserAccess? get accessData => _accessData;

  ///Returns the status of the access token
  TokenStatus? _accessStatus;
  TokenStatus? get accessStatus => _accessStatus;

  /// Returns the status of the refresh token
  TokenStatus? _refreshStatus;
  TokenStatus? get refreshStatus => _refreshStatus;

  Future<void> init() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    if (!sharedPreferences.containsKey('login')){
      return;
    }

    // acquire keys first
    // check token status of refresh token
    // if refresh token is good, proceed to check access token
    Map<String, dynamic> tokens = await _sharedPrefsUtils.getTokens(
        sharedPrefsInstance: sharedPreferences
    );
    String? refreshToken = tokens['refresh'];
    String? accessToken = tokens['access'];

    _refreshStatus = await _authUtils.verifyToken(
      token: refreshToken,
      refresh: true
    );

    if (_refreshStatus == TokenStatus.invalid) {
      _globalNavigator.forceLoginDialog();
      return;
    } else if (_refreshStatus == TokenStatus.expired) {
      _globalNavigator.forceLoginDialog();
      return;
    } else if (_refreshStatus == TokenStatus.unverified) {
      // TODO handle unverified refresh token status
    } else if (_refreshStatus == TokenStatus.valid) {
      _accessStatus = await _authUtils.verifyToken(
          token: accessToken
      );
    }

    if ([TokenStatus.invalid, TokenStatus.expired].contains(_accessStatus)) {
      // if refresh is valid refresh access token
      if (_refreshStatus == TokenStatus.valid) {
        accessToken = await _authUtils.refreshAccessToken(
            refresh: refreshToken!
        );
      } else if (_refreshStatus == TokenStatus.unverified) {
        _logs.warning(message: 'refresh token unverified but access status invalid, this will be allowed for now');
      }
    } else if (_accessStatus == TokenStatus.unverified) {
      _logs.warning(message: 'access status unverified, this will be allowed for now');
    }
    _accessData = UserAccess.fromJSON(
        _authUtils.parseToken(token: accessToken)!
    );
    _accessStatus = TokenStatus.valid;

    _sharedPrefsUtils.setTokens(
        tokens: {
          Tokens.refresh: refreshToken,
          Tokens.access: accessToken
        }
    );

    _logs.success(message: 'init() done');

    notifyListeners();
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