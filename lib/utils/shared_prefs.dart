import 'package:shared_preferences/shared_preferences.dart';
import 'package:smmic/models/auth_models.dart';

class SharedPrefsUtils {
  ///Checks if an access token already exists in the SharedPreferences, stores new token or replaces token if not
  Future<void> setAccess(String access) async {
    try {
      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      if (sharedPreferences.getString('access') == access) {
        return;
      }
      await sharedPreferences.setString('access', access);
    } catch(error) {
      Exception(error);
    }
  }

  ///Get the access token from shared prefs, returns null if sharedprefs has no 'token' key or if 'token' is null
  Future<String?> getAccess() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    try {
      if (!sharedPreferences.containsKey('access') || sharedPreferences.getString('access') == null) {
        return null;
      }
      return sharedPreferences.getString('access');
    } catch(error) {
      Exception(error);
      return null;
    }
  }

  ///Checks if a refresh token already exists in the SharedPreferences, stores new token or replaces token if not
  Future<void> setRefresh(String refresh) async {
    try {
      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      if (sharedPreferences.getString('refresh') == refresh) {
        return;
      }
      await sharedPreferences.setString('refresh', refresh);
    } catch(error) {
      Exception(error);
    }
  }

  ///Get the refresh token from shared prefs, returns null if sharedprefs has no 'token' key or if 'token' is null
  Future<String?> getRefresh() async {
    try {
      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      if (!sharedPreferences.containsKey('refresh') || sharedPreferences.getString('refresh') == null) {
        return null;
      }
      return sharedPreferences.getString('refresh');
    } catch(error) {
      Exception(error);
      return null;
    }
  }
}