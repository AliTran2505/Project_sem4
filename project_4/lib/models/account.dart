import 'package:intl/intl.dart';

class Account {
  final int accountID;
  final String userName;
  final String? password;
  final String email;
  final String phoneNumber;
  final String address;
  final String? roleName; // Nullable
  final bool? status;     // Nullable
  final DateTime? createDate; // Nullable
  final DateTime? lastUpdateDate; // Nullable

  Account({
    required this.accountID,
    required this.userName,
    this.password,
    required this.email,
    required this.phoneNumber,
    required this.address,
    this.roleName,
    this.status,
    this.createDate,
    this.lastUpdateDate,
  });

  // Convert a JSON map to an Account instance
  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      accountID: json['accountID'],
      userName: json['userName'],
      password: json['password'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      address: json['address'],
      roleName: json['roleName'],
      status: json['status'],
      createDate: json['createDate'] != null ? DateTime.parse(json['createDate']) : null,
      lastUpdateDate: json['lastUpdateDate'] != null ? DateTime.parse(json['lastUpdateDate']) : null,
    );
  }

  // Convert an Account instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'accountID': accountID,
      'userName': userName,
      'password': password,
      'email': email,
      'phoneNumber': phoneNumber,
      'address': address,
      'roleName': roleName,
      'status': status,
      'createDate': createDate != null ? DateFormat('yyyy-MM-ddTHH:mm:ss').format(createDate!) : null,
      'lastUpdateDate': lastUpdateDate != null ? DateFormat('yyyy-MM-ddTHH:mm:ss').format(lastUpdateDate!) : null,
    };
  }
}
