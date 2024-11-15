/// Defines API constants (routes, configs if any)
class ApiRoutes {
  //10.0.2.2
  final String _baseURL = 'http://192.168.1.8:8000/api';
  final String _loginURL = '/auth/jwt/create/';
  final String _logoutURL = '/blacklist';
  final String _registerURL = '/djoser/users/';
  final String _getUserURL = '/djoser/users/me/';
  final String _verifyTokenURL = '/auth/jwt/verify';
  final String _refreshAccessURL = '/auth/jwt/refresh';
  final String _getDevicesURL = '/getuserSKdevices';
  final String _updateUserData = '/updateuserdetails/';
  final String _updateSKDeviceName = '/updateuserSKdevicesname/';
  final String _updateSNDeviceName = '/updateuserSNdevicesname/';

  ///FCM URL
  final String _notifications = '/devices/';


  ///Django Channels/Websocket URL Connections
  final String _wsBaseURL = 'ws://192.168.1.8:8000/ws';
  final String _seReadingsWs = '/SNreadings/';
  final String _getSMAlerts = '/sm_alerts/';



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

  ///Update SK Name
  String get updateSKName => '$_baseURL$_updateSKDeviceName';

  ///Update SN Name
  String get updateSNName => '$_baseURL$_updateSNDeviceName';

  ///Get SN Readings
  String get seReadingsWs => '$_wsBaseURL$_seReadingsWs';

  ///Get SMAlerts
  String get seAlertsWs => '$_wsBaseURL$_getSMAlerts';

  ///FCM Notifications
  String get deviceNotifications => '$_baseURL$_notifications';
}
