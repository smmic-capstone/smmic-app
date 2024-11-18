import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smmic/models/device_data_models.dart';

String defaultFont = 'Inter';

TextTheme _textTheme = const TextTheme(
    displayLarge: TextStyle(
        fontFamily: 'Inter', fontSize: 60, fontWeight: FontWeight.bold));

class UiProvider extends ChangeNotifier {
  bool _isDark = false;
  bool get isDark => _isDark;

  //custom darkTheme
  final darkTheme = ThemeData(
      primaryColor: Colors.black12,
      brightness: Brightness.dark,
      primaryColorDark: Colors.black12);

  final lightTheme = ThemeData(
      textTheme: _textTheme,
      primaryColor: Colors.white,
      brightness: Brightness.light,
      primaryColorDark: Colors.white);

//toggle button
  changeTheme() async {
    _isDark = !isDark;
    await _saveTheme();
    notifyListeners();
  }

  UiProvider() {
    _themeLoad();
  }

  Future<void> _themeLoad() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isDark = prefs.getBool('isDark') ?? false;
    notifyListeners();
  }

  Future<void> _saveTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDark', _isDark);
  }

  Color setConnectionColor(ConnectivityResult connectionStatus, int sensorConnectionState) {
    Color finalColor = const Color.fromRGBO(76, 166, 42, 0.9);
    if (connectionStatus == ConnectivityResult.none
        || sensorConnectionState == SMSensorAlertCodes.disconnectedState.code) {
      finalColor = Colors.black.withOpacity(0.2);
    }
    return finalColor;
  }
}