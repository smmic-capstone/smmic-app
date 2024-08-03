import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smmic/constants/api.dart';
import 'package:http/http.dart' as http;
import 'package:smmic/models/auth_models.dart';
import 'package:smmic/providers/user_data_providers.dart';
import 'package:smmic/services/user_data_services.dart';

class AuthService {

  final ApiRoutes _apiRoutes = ApiRoutes();
  final UserDataServices _userDataServices = UserDataServices();
  final AuthProvider _authProvider = AuthProvider();

  /// Checks if a session already exists in sharedprefs, or if session has already expired
  Future<bool> checkSession() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (!sharedPreferences.containsKey('token')) {
      return false;
    }
    if (sharedPreferences.getString('token') == null) {
      return false;
    }
    return await verifySession(token: sharedPreferences.getString('token')!) == SessionStatus.verified;
  }

  /// Verifies a session token from API
  Future<SessionStatus> verifySession({required String token}) async {
    //TODO: implement verifySession
    return SessionStatus.verified;
  }

  Future<int?> login({required String email, required String password}) async {
    try{
      final response = await http.post(Uri.parse(_apiRoutes.loginURL), body: {
        'email' : email,
        'password' : password
      });
      // 500 error code
      if (response.statusCode == 500){
        return response.statusCode;
      }

      // if wrong credentials
      if(response.statusCode == 401){
        return response.statusCode;
      }
      // successful
      if (response.statusCode == 200){
        final jsonData = jsonDecode(response.body);
        _authProvider.createSession(token: jsonData['access']);
      }
    } catch(error) {
      //TODO: define error handling
    }
    return null;
  }

  Future<int?> logout({required String userID}) async {
    //TODO: implement logout
  }


}