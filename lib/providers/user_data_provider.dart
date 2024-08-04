import 'package:flutter/material.dart';
import 'package:smmic/models/user_data_model.dart';

class UserDataProvider extends ChangeNotifier {
  User? _user;
  User? get user => _user;

  void initUser({required Map<String, dynamic> userData}) {
    _user = User.fromJson(userData);
  }

}