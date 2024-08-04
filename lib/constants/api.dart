/// Defines API constants (routes, configs if any)
class ApiRoutes {
  final String _baseURL = 'http://10.0.2.2:8000/api';
  final String _loginURL = '/auth/jwt/create/';
  final String _logoutURL = '/blacklist';
  final String _getUserURL = '/djoser/users/me/';
  final String _verifyTokenURL = '/auth/jwt/verify';
  final String _refreshAccessURL = '/auth/jwt/refresh';

  /// Base url for the api
  //String get baseURL => _baseURL;

  /// Login URL, requires email and password
  String get login => '$_baseURL$_loginURL';

  /// Logout URL, blacklists refresh token of user, requires refresh token
  String get logout => '$_baseURL$_logoutURL';

  /// Fetch user data, requires access token
  String get getUserData => '$_baseURL$_getUserURL';

  String get verifyToken => '$_baseURL$_verifyTokenURL';

  String get refreshToken => '$_baseURL$_refreshAccessURL';
}