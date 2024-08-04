import 'package:jwt_decode/jwt_decode.dart';
import 'package:smmic/models/auth_models.dart';
import 'package:flutter/material.dart';
import 'package:smmic/utils/auth_utils.dart';
import 'package:smmic/utils/datetime_formatting.dart';
import 'package:smmic/utils/shared_prefs.dart';

///Specifies current status of the token
enum TokenStatus {
  pending, /// Pending verification from API
  valid, /// Validated from API
  invalid, /// Invalid token
  expired, /// Expired token
  unverified, /// Cannot verify
  forceLogin ///
}

class AuthProvider extends ChangeNotifier {
  final AuthUtils _authUtils = AuthUtils();

  UserAccess? _accessData; //= init()['data'];
  TokenStatus? _accessStatus;

  ///Returns current access data
  UserAccess? get accessData => _accessData;

  ///Returns current access status
  TokenStatus? get accessStatus => _accessStatus;
  
  Future<void> init() async {
    Map<String, dynamic> initData = await _authUtils.initAccess();
    Map<String, dynamic> parsedToken = Jwt.parseJwt(initData['token']);
    if (_checkSessionInstance(parsedToken) != null){
      return;
    }
    _accessData = UserAccess.fromJSON({
      'token' : initData['token'],
      'user_id' : parsedToken['user_id'],
      'token_identifier' : parsedToken['jti'],
      'created' : parsedToken['iat'],
      'expires' : parsedToken['exp']
    });
    _accessStatus = initData['status'];
  }
  
  //Create a session object with the session token
  Future<void> setAccess({required String token}) async {
    Map<String, dynamic> parsedToken = Jwt.parseJwt(token);
    if (_checkSessionInstance(parsedToken) != null) {
      return;
    }
    _accessData = UserAccess.fromJSON({
      'token' : token,
      'user_id' : parsedToken['user_id'],
      'token_identifier' : parsedToken['jti'],
      'created' : parsedToken['iat'],
      'expires' : parsedToken['exp']
    });
    notifyListeners();
  }

  Future<void> setAccessStatus() async {
    if(_accessData != null) {
      _accessStatus = await _authUtils.verifyToken(token: _accessData!.token, refresh: false);
    }
    //TODO: handle if invalid, expired or unverified
    notifyListeners();
  }

  /// Checks if the session instance already exists, returns the _sessionData if instance already exists or if existing instance somehow expires later than new token
  UserAccess? _checkSessionInstance(Map<String, dynamic> parsedToken) {
    if (_accessData != null) {
      if (_accessData!.tokenIdentifier == parsedToken['jti']) {
        return _accessData;
      }
      if (_accessData!.expires.compareTo(DateTimeFormatting().fromJWTSeconds(parsedToken['exp'])) > 0) {
        return _accessData;
      }
    }
    return null;
  }

}