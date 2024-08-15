import 'package:flutter/material.dart';


String defaultFont = 'Inter';

TextTheme _textTheme = const TextTheme(
  displayLarge: TextStyle(
      fontFamily: 'Inter',
      fontSize: 60,
      fontWeight: FontWeight.bold
  )
);

class UiProvider extends ChangeNotifier {
  bool _isDark = false;
  bool get isDark => _isDark;

  //custom darkTheme
  final darkTheme = ThemeData(
      primaryColor: Colors.black12,
      brightness: Brightness.dark,
      primaryColorDark: Colors.black12
  );

  final lightTheme = ThemeData(
      textTheme: _textTheme,
      primaryColor: Colors.white,
      brightness: Brightness.light,
      primaryColorDark: Colors.white
  );

//toggle button
  changTheme() {
    _isDark = !isDark;
    notifyListeners();
  }

  init() {
    notifyListeners();
  }
}