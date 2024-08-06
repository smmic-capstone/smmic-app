import 'package:flutter/material.dart';
import 'package:smmic/models/user_data_model.dart';
import 'package:smmic/providers/auth_provider.dart';
import 'package:smmic/services/user_data_services.dart';
import 'package:smmic/utils/shared_prefs.dart';

class UserDataProvider extends ChangeNotifier {
  //Dependencies
  final SharedPrefsUtils _sharedPrefsUtils = SharedPrefsUtils();
  final UserDataServices _userDataServices = UserDataServices();
  final AuthProvider _authProvider = AuthProvider();

  User? _user;
  User? get user => _user;

  Future<void> init() async {
    Map<String, dynamic>? userData = await _sharedPrefsUtils.getUserData();
    if(userData == null){
      Map<String, dynamic> onSharedPrefsEmpty = await _onSharedPrefsEmpty();
      if(onSharedPrefsEmpty.containsKey('logged_out')){
        return;
      }
      if(onSharedPrefsEmpty.containsKey('error')){
        throw onSharedPrefsEmpty['error'];
      }
      _user = User.fromJson(onSharedPrefsEmpty);
    }
    if(userData!.containsKey('error')){
      throw userData['errors'];
    }
    //TODO: implement crosscheck with api to verify user data
    _user = User.fromJson(userData);
    notifyListeners();
  }

  /// Triggered when user data from SharedPreferences does not exist.
  ///
  /// If current session is logged out, returns a `{logged_out: true}` key:value pair, otherwise, attempts to query the api for user data
  Future<Map<String, dynamic>> _onSharedPrefsEmpty() async {
    String? login = await _sharedPrefsUtils.getLogin();
    if (login == null){
      return {'logged_out': true};
    } else {
      Map<String, dynamic>? userDataFromApi;
      try{
        userDataFromApi = await _userDataServices.getUserInfo(token: _authProvider.accessData!.token);
        return userDataFromApi ?? {'error' : 'unexpected error on UserDataProvider._userDataServices, no user data from API ??'};
      } catch (e) {
        return {'error': e.toString()};
      }
    }
  }

  //TODO: implement userDataChange

}