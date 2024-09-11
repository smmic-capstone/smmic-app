import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UiProvider extends ChangeNotifier {
  bool _isDark = false;
  bool get isDark => _isDark;

  //custom darktheme
  final darktheme = ThemeData(
      primaryColor: Colors.black12,
      brightness: Brightness.dark,
      primaryColorDark: Colors.black12);

  final lightTheme = ThemeData(
      primaryColor: Colors.white,
      brightness: Brightness.light,
      primaryColorDark: Colors.white);

//toggle button
  changTheme() async {
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
}
