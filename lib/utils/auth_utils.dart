import 'dart:convert';

import 'package:jwt_decode/jwt_decode.dart';
import 'package:smmic/constants/api.dart';
import 'package:smmic/providers/auth_provider.dart'; //Token status
import 'package:http/http.dart' as http;
import 'package:smmic/utils/datetime_formatting.dart';
import 'package:smmic/utils/shared_prefs.dart';


class AuthUtils {
  final ApiRoutes _apiRoutes = ApiRoutes();
  final SharedPrefsUtils _sharedPrefsUtils = SharedPrefsUtils();
  final DateTimeFormatting _dateTimeFormatting = DateTimeFormatting();

  ///Verifies token validity from api, useful for validating access from and to database
  Future<TokenStatus> verifyToken({required String token}) async {
    Map<String, dynamic> parsed = Jwt.parseJwt(token);
    if (_dateTimeFormatting.fromJWTSeconds(parsed['exp']).compareTo(DateTime.now()) < 0) {
      return TokenStatus.expired;
    }
    try{
      final response = await http.post(Uri.parse(_apiRoutes.verifyToken), body:{'token': token});
      if (response.statusCode == 400 && (jsonDecode(response.body) as Map<String, dynamic>).containsKey('non_field_errors')) {
        return TokenStatus.invalid;
      }
      if (response.statusCode == 200) {
        return TokenStatus.valid;
      }
    } catch(e) {
      Exception(e);
    }
    return TokenStatus.unverified;
  }

}