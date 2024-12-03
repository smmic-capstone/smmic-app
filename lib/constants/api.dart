/// Defines API constants (routes, configs if any)
class ApiRoutes {
  //10.0.2.2
  final String _baseURL = 'http://goeasyonme.pythonanywhere.com/api';
  final String _loginURL = '/auth/jwt/create/';
  final String _logoutURL = '/blacklist/';
  final String _registerURL = '/djoser/users/';
  final String _getUserURL = '/djoser/users/me/';
  final String _verifyTokenURL = '/auth/jwt/verify';
  final String _refreshAccessURL = '/auth/jwt/refresh';
  final String _getDevicesURL = '/getuserSKdevices/';
  final String _updateUserData = '/updateuserdetails/';
  final String _updateSKDeviceName = '/updateuserSKdevicesname/';
  final String _updateSNDeviceName = '/updateuserSNdevicesname/';
  final String _pusherAuth = '/pusher/user-auth/';

  // readings endpoint
  final String _getSensorReadings = '/getSNreadings';
  final String _getSinkReadings = '/getSKreadings';

  ///FCM URL
  final String _notifications = '/devices/';

  ///Pusher Channels/Websocket URL Connections
  final String _seReadingsWs = 'sensor_readings';
  final String _getSMAlerts = 'sensor_alerts';
  final String _getSendCommands = 'private-user_commands';
  final String _skReadingsWs = 'sink_readings';

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
  String get seReadingsWs => _seReadingsWs;

  ///Get SMAlerts
  String get seAlertsWs => _getSMAlerts;

  ///PusherAuthentication
  String get pusherAuth => '$_baseURL$_pusherAuth';

  ///Get sendCommands
  String get userCommands => _getSendCommands;

  ///FCM Notifications
  String get deviceNotifications => '$_baseURL$_notifications';

  String get getSensorReadings => '$_baseURL$_getSensorReadings';
  String get getSinkReadings => '$_baseURL$_getSinkReadings';
  String get sinkReadingsWs => _skReadingsWs;
}