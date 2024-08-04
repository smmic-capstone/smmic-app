import 'package:shared_preferences/shared_preferences.dart';
import 'package:smmic/models/auth_models.dart';

enum Tokens{
  refresh,
  access
}

class SharedPrefsUtils {
  ///Gets `refresh` and `access` tokens from SharedPreferences. Returns both tokens by default
  Future<Map<String, dynamic>> getTokens({bool? refresh, bool? access}) async {
    Map<String, dynamic> tokens = {};
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? refreshToken = sharedPreferences.getString('refresh');
    String? accessToken = sharedPreferences.getString('access');
    if(refresh == null && access == null){
      tokens.addAll({'refresh':refreshToken, 'access':accessToken});
      return tokens;
    }
    if(refresh != null && refresh){
      tokens.addAll({'refresh':refreshToken});
    }
    if(access != null && access){
      tokens.addAll({'access':accessToken});
    }
    return tokens;
  }

  ///Stores tokens to SharedPreferences
  Future<void> setToken({required Map<Tokens, dynamic> tokens}) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (tokens.containsKey(Tokens.refresh) && tokens[Tokens.refresh] != null){
      await sharedPreferences.setString('refresh', tokens[Tokens.refresh]);
    }
    if(tokens.containsKey(Tokens.access) && tokens[Tokens.access] != null){
      await sharedPreferences.setString('access', tokens[Tokens.access]);
    }
    return;
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