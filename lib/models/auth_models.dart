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
      tokenIdentifier: accessData['token_id'],
      created: DateTimeFormatting().fromJWTSeconds(accessData['created']),
      expires: DateTimeFormatting().fromJWTSeconds(accessData['expires']),
    );
    return userSession;
  }
}