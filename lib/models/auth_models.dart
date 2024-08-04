import 'package:smmic/utils/datetime_formatting.dart';

class UserAccess {
  final String token;
  final String userID;
  final String tokenIdentifier;
  final DateTime created;
  final DateTime expires;

  UserAccess._internal({
    required this.token,
    required this.userID,
    required this.tokenIdentifier,
    required this.created,
    required this.expires
  });

  factory UserAccess.fromJSON(Map<String, dynamic> accessData) {
    UserAccess userSession = UserAccess._internal(
      token: accessData['token'],
      userID: accessData['user_id'],
      tokenIdentifier: accessData['token_identifier'],
      created: DateTimeFormatting().fromJWTSeconds(accessData['created']),
      expires: DateTimeFormatting().fromJWTSeconds(accessData['expires']),
    );
    return userSession;
  }
}

// I/flutter ( 9929): Instance of 'Future<String?>'
// I/flutter ( 9929): {token_type: access, exp: 1722733712, iat: 1722722912, jti: 69676a4d66e949de811d39d674c62bfb, user_id: 77800344-4479-4e1f-a35e-b9675409ea66}
// E/flutter ( 9929): [ERROR:flutter/runtime/dart_vm_initializer.cc(41)] Unhandled Exception: type 'Null' is not a subtype of type 'num'
// E/flutter ( 9929): #0      new UserAccess.fromJSON (package:smmic/models/auth_models.dart:23:63)
// E/flutter ( 9929): #1      AuthProvider.createAccess (package:smmic/providers/auth_provider.dart:31:30)
// E/flutter ( 9929): #2      AuthService.login (package:smmic/services/auth_services.dart:35:23)
// E/flutter ( 9929): <asynchronous suspension>