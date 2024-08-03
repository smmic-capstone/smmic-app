class UserSession {
  final String userID;
  final String token;
  final DateTime sessionCreated;

  UserSession._internal({
    required this.userID,
    required this.token,
    required this.sessionCreated
  });

  factory UserSession.fromJSON(Map<String, dynamic> sessionData) {
    return UserSession._internal(
      userID: sessionData['userID'],
      token: sessionData['token'],
      sessionCreated: sessionData['created']
    );
  }
}

