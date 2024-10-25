import 'package:flutter/material.dart';
import 'package:project_4/models/account.dart';
import 'package:project_4/services/account_service.dart';

class UpdateProfilePage extends StatefulWidget {
  final Map<String, dynamic> userInfo;

  UpdateProfilePage({required this.userInfo});

  @override
  _UpdateProfilePageState createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {
  final AccountService _accountService = AccountService();
  late TextEditingController _userNameController;
  late TextEditingController _passwordController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _userNameController = TextEditingController(text: widget.userInfo['userName']);
    _passwordController = TextEditingController(text: widget.userInfo['password']);
    _emailController = TextEditingController(text: widget.userInfo['email']);
    _phoneController = TextEditingController(text: widget.userInfo['phoneNumber']);
    _addressController = TextEditingController(text: widget.userInfo['address']);
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

 Future<void> _updateProfile() async {
    final account = Account(
      accountID: widget.userInfo['accountID'], // Giả sử bạn có trường này trong userInfo
      userName: _userNameController.text,
      password: _passwordController.text.isNotEmpty
          ? _passwordController.text // Sử dụng mật khẩu mới nếu có
          : widget.userInfo['password'], // Nếu không, giữ nguyên mật khẩu cũ
      email: _emailController.text,
      phoneNumber: _phoneController.text,
      address: _addressController.text,
      status: true, // Status mặc định
    );

    try {
      bool success = await _accountService.updateAccount(account);
      if (success) {
        Navigator.pop(context); // Quay lại trang ProfilePage
      } else {
        // Hiển thị thông báo lỗi
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cập nhật thông tin không thành công')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sửa thông tin'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _userNameController, decoration: InputDecoration(labelText: 'Họ và tên')),
             TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Mật khẩu'),
              obscureText: true, 
            ),
            TextField(controller: _emailController, decoration: InputDecoration(labelText: 'Email')),
            TextField(controller: _phoneController, decoration: InputDecoration(labelText: 'Số điện thoại')),
            TextField(controller: _addressController, decoration: InputDecoration(labelText: 'Địa chỉ')),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateProfile,
              child: Text('Lưu thay đổi'),
            ),
          ],
        ),
      ),
    );
  }
}
