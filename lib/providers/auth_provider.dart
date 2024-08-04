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
  forceLogin /// Force re log in
}

///Authentication Provider
class AuthProvider extends ChangeNotifier {

  //Dependencies
  final AuthUtils _authUtils = AuthUtils();

  ///Returns the access data
  UserAccess? _accessData;
  UserAccess? get accessData => _accessData;

  ///Returns the access status
  TokenStatus? _accessStatus;
  TokenStatus? get accessStatus => _accessStatus;

  Future<void> init() async {
    Map<String, dynamic> tokens = await _sharedPrefsUtils.getTokens();
    bool forceLogin = await _authUtils.forceLoginCheck(refresh: tokens['refresh']);
    if(forceLogin){
      _accessData = null;
      _accessStatus = TokenStatus.forceLogin;
      notifyListeners();
      return;
    }
    TokenStatus accessStatus = await _authUtils.verifyToken(token: tokens['access']);
    if (accessStatus != TokenStatus.valid) {
      String? newAccess = await _authUtils.refresh(refresh: tokens['refresh']);
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

  Future<void> setAccess({required String token}) async {
    Map<String, dynamic> parsedToken = _authUtils.parseToken(token: token)!;
    if (_checkSessionInstance(parsedToken) != null) {
      return;
    } else {
      TokenStatus accessStatus = await _authUtils.verifyToken(token: token);
      _accessData = UserAccess.fromJSON(_authUtils.parseToken(token: token)!);
      _accessStatus = accessStatus;
    }
    notifyListeners();
  }

  UserAccess? _checkSessionInstance(Map<String, dynamic> parsedToken) {
    if (_accessData == null) {
      return null;
    }
    if (_accessData!.tokenIdentifier == parsedToken['jti']) {
      return _accessData;
    }
    DateTime expires = DateTimeFormatting().fromJWTSeconds(parsedToken['exp']);
    if (_accessData!.expires.isAfter(expires)) {
      return _accessData;
    }
    return null;
  }

}