import 'package:flutter/material.dart';
import 'package:smmic/models/user_data_model.dart';

class UserDataProvider extends ChangeNotifier {
  User? _user;
  User? get user => _user;

  void init() {
    //_user = User.fromJson(userData);
  }

}