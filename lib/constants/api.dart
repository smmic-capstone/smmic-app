import 'package:flutter/material.dart';

/// Defines API constants (routes, configs if any)
class ApiRoutes {
  final String _baseURL = 'http://10.0.2.2:8000/api';
  final String _loginURL = '/auth/jwt/create/';
  final String _getUserURL = '/djoser/users/me/';

  String get baseURL => _baseURL;
  String get loginURL => '$_baseURL$_loginURL';
  String get getUserURL => '$_baseURL$_getUserURL';
}