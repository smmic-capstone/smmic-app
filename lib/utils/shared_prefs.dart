import 'package:jwt_decode/jwt_decode.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smmic/models/auth_models.dart';
import 'package:smmic/utils/datetime_formatting.dart';

enum Tokens{
  refresh,
  access
}

class SharedPrefsUtils {
  final DateTimeFormatting _dateTimeFormatting = DateTimeFormatting();
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

  ///Stores tokens to SharedPreferences.
  ///
  ///Receives a Key:Value map using Tokens enums as keys (Tokens.refresh or Tokens.access)
  Future<void> setTokens({required Map<Tokens, dynamic> tokens}) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (tokens.containsKey(Tokens.refresh) && tokens[Tokens.refresh] != null){
      await sharedPreferences.setString('refresh', tokens[Tokens.refresh]);
    }
    if(tokens.containsKey(Tokens.access) && tokens[Tokens.access] != null){
      await sharedPreferences.setString('access', tokens[Tokens.access]);
    }
    return;
  }

  ///Sets the login timestamp
  Future<void> setLoginFromRefresh({required String refresh}) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Map<String, dynamic> parsed = Jwt.parseJwt(refresh);
    String timestamp = _dateTimeFormatting.fromJWTSeconds(parsed['iat']).toString();
    await sharedPreferences.setString('login', timestamp);
  }

  Future<String?> getLogin() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString('login');
  }

  /// This function clears both refresh and access tokens from SharedPreferences.
  ///
  /// Useful when a forceLogin is required or when the user logs out. Outside of those two scenarios, use with caution.
  Future<void> clearTokens() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.remove('refresh');
    await sharedPreferences.remove('access');
    await sharedPreferences.remove('login');
  }

  Future<void> userData({required Map<String,dynamic> userInfo}) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setStringList('user_info',userInfo.keys.map((item) => userInfo[item].toString()).toList());
  }
}