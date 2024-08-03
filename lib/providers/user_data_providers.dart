import 'package:flutter/material.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:smmic/models/auth_models.dart';
import 'package:smmic/models/user_data_model.dart';

enum SessionStatus {
  pending, /// Pending verification from API
  verified, /// Validated from API
  unverified, /// Unvalidated from API
  expired, /// Expired token
}

class UserDataProvider extends ChangeNotifier {
  User? _user;
  User? get user => _user;

  void initUser({required Map<String, dynamic> userData}) {
    _user = User.fromJson(userData);
  }

}

class AuthProvider extends ChangeNotifier {

  UserSession? _sessionData;
  SessionStatus _sessionStatus = SessionStatus.unverified;

  UserSession? get sessionData => _sessionData;
  SessionStatus get sessionStatus => _sessionStatus;

  //create a session object with the session token
  void createSession({required String token}) {
    Map<String, dynamic> parsedToken = Jwt.parseJwt(token);
    Map<String, dynamic> sessionData = {
      'token' : token,
      'userID' : parsedToken['user_id'],
      'tokenIdentifier' : parsedToken['jti'],
      'created' : parsedToken['iat'],
      'expires' : parsedToken['exp']
    };
    _sessionData = UserSession.fromJSON(sessionData);
    notifyListeners();
  }

  void setStatus(SessionStatus status) {
    _sessionStatus = status;
  }

}