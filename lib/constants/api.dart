/// Defines API constants (routes, configs if any)
class ApiRoutes {
  final String _baseURL = 'http://localhost:8000/api';
  final String _loginURL = '/auth/jwt/create/';
  final String _logoutURL = '/blacklist';
  final String _registerURL = '/djoser/users/';
  final String _getUserURL = '/djoser/users/me/';
  final String _verifyTokenURL = '/auth/jwt/verify';
  final String _refreshAccessURL = '/auth/jwt/refresh';
  final String _getDevicesURL = '/getuserSKdevices/';
  final String _updateUserData = '/updateuserdetails/';
  
  /// Base url for the api
  //String get baseURL => _baseURL;

  /// Login URL, requires email and password
  String get login => '$_baseURL$_loginURL';

  /// Logout URL, blacklists refresh token of user, requires refresh token
  String get logout => '$_baseURL$_logoutURL';

  ///Register new user
  String get register => '$_baseURL$_registerURL';

  /// Fetch user data, requires access token
  String get getUserData => '$_baseURL$_getUserURL';

  ///Verify Token validity. Useful on errors with authentication
  String get verifyToken => '$_baseURL$_verifyTokenURL';

  ///Refreshes access token, requires the refresh token
  String get refreshToken => '$_baseURL$_refreshAccessURL';

  /// Get user's registered devices
  String get getDevices => '$_baseURL$_getDevicesURL';

  ///Update User Data
  String get updateData => '$_baseURL$_updateUserData';
}