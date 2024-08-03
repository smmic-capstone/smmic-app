class User {
  final String userID;
  String firstName;
  String lastName;
  String email;
  String zipCode;
  String zone;
  String barangay;
  String city;
  String province;
  String profilePicLink;

  Map<String, User> _cache = {};

  User._internal({
    required this.userID,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.zipCode,
    required this.zone,
    required this.barangay,
    required this.city,
    required this.province,
    required this.profilePicLink
  });

  factory User.fromJson(Map<String, dynamic> userData) {
    return User._internal(
        userID: userData['UID'],
        firstName: userData['first_name'],
        lastName: userData['last_name'],
        email: userData['email'],
        zipCode: userData['zip_code'],
        zone: userData['zone'],
        barangay: userData['barangay'],
        city: userData['city'],
        province: userData['province'],
        profilePicLink: userData['profilepic']
    );
  }
}