class LoginResponse {
  final String token;
  final UserData userData;

  LoginResponse({required this.token, required this.userData});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'],
      userData: UserData.fromJson(json['userData']),
    );
  }
}

class UserData {
  final int accountID;
  final String userName;
  final String roleName;
  final String email;
  final String phoneNumber;
  final String address;
  final bool status;
  final DateTime createAt;
  final DateTime lastUpdateAt;

  UserData({
    required this.accountID,
    required this.userName,
    required this.roleName,
    required this.email,
    required this.phoneNumber,
    required this.address,
    required this.status,
    required this.createAt,
    required this.lastUpdateAt,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      accountID: json['accountID'],
      userName: json['userName'],
      roleName: json['roleName'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      address: json['address'],
      status: json['status'],
      createAt: DateTime.parse(json['createAt']),
      lastUpdateAt: DateTime.parse(json['lastUpdateAt']),
    );
  }
}
