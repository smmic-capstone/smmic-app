import 'package:flutter/material.dart';
import 'package:smmic/models/user_data_model.dart';
import 'package:smmic/providers/auth_provider.dart';
import 'package:smmic/services/user_data_services.dart';
import 'package:smmic/utils/logs.dart';
import 'package:smmic/utils/shared_prefs.dart';

class UserDataProvider extends ChangeNotifier {
  //Dependencies
  final SharedPrefsUtils _sharedPrefsUtils = SharedPrefsUtils();
  final UserDataServices _userDataServices = UserDataServices();
  final AuthProvider _authProvider = AuthProvider();
  final Logs _logs = Logs(tag: 'UserDataProvider');

  User? _user;
  User? get user => _user;

  Future<void> init() async {
    _logs.info2(message: 'init() executing');
    Map<String, dynamic>? userData = await _sharedPrefsUtils.getUserData();
    if(userData != null){
      _user = User.fromJson(userData);
      await _sharedPrefsUtils.setUserData(userInfo: userData);
      _logs.success(message: 'init() done without warnings or error');
    } else {
      _logs.warning(message: 'useData is null, executing _onSharedPrefsEmpty()');
      Map<String, dynamic> onSharedPrefsEmpty = await _onSharedPrefsEmpty();

      //TODO: HANDLE ERROR
      if(onSharedPrefsEmpty.containsKey('error')){
        _logs.critical(message: 'onSharedPrefsEmpty returned with `error` key');
        throw onSharedPrefsEmpty['error'];
      }

      // TODO: CREATE CROSS CHECKING WITH API FUNCTION
      _logs.info(message: '_onSharedPrefsEmpty() returned with data');
      _user = User.fromJson(onSharedPrefsEmpty);
      await _sharedPrefsUtils.setUserData(userInfo: onSharedPrefsEmpty);
      _logs.success(message: 'init() done');
      notifyListeners();
    }
  }

  /// Triggered when user data from SharedPreferences does not exist.
  ///
  /// If current session is logged out, returns a `{logged_out: true}` key:value pair, otherwise, attempts to query the api for user data
  Future<Map<String, dynamic>> _onSharedPrefsEmpty() async {
    String? login = await _sharedPrefsUtils.getLogin();
    Map<String, dynamic> tokens = await _sharedPrefsUtils.getTokens(access: true);
    if (login == null){
      return {'logged_out': true};
    } else {
      Map<String, dynamic>? userDataFromApi;
      _logs.info(message: 'userDataFromAPI: ${tokens['access']}');
      try{
        userDataFromApi = await _userDataServices.getUserInfo(token: tokens['access']);
        // TODO: HANDLE IF ERROR
        return userDataFromApi!['data'];
      } catch (e) {
        return {'error': e.toString()};
      }
    }
  }

  //TODO: implement userDataChange

}