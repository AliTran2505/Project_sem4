import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:project_4/models/account.dart';
import 'package:project_4/models/login_response.dart';

class AccountService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://art.somee.com/',
    connectTimeout: Duration(seconds: 10),
    receiveTimeout: Duration(seconds: 10),
  ));

  final FlutterSecureStorage _storage = FlutterSecureStorage();

  // Đăng nhập và lưu token
  Future<bool> login(String username, String password) async {
    try {
      final response = await _dio.post('api/AccountControllers/login', data: {
        'userName': username,
        'password': password,
      });

      if (response.statusCode == 200) {
        final loginResponse = LoginResponse.fromJson(response.data);

        // Lưu token vào secure storage
        await _storage.write(key: 'token', value: loginResponse.token);

        // Giải mã token để lấy role
        Map<String, dynamic> decodedToken = JwtDecoder.decode(loginResponse.token);
        String roleName = decodedToken['role'];

        // Kiểm tra roleName và trả về true nếu là user
        if (roleName == 'user') {
          return true;
        } else {
          // Xóa token nếu không phải user
          await _storage.delete(key: 'token');
          return false;
        }
      } else {
        return false;
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 405) {
        throw Exception('Method Not Allowed: ${e.response?.statusMessage}');
      } else {
        throw Exception('Failed to login: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to login: $e');
    }
  }

  // Đăng xuất và xóa token
  Future<void> logout() async {
    await _storage.delete(key: 'token');
  }

  // Lấy thông tin người dùng hiện tại
  Future<Map<String, dynamic>> getMe() async {
    try {
      final token = await _storage.read(key: 'token');
      if (token == null) {
        print('Token not found');
        throw Exception('Token not found');
      }
      
      print('Retrieved Token: $token');
      _dio.options.headers['Authorization'] = 'Bearer $token';
      final response = await _dio.get('/accounts/me');

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to get user info');
      }
    } catch (e) {
      throw Exception('Failed to get user info: $e');
    }
  }

  // Thêm tài khoản mới
  Future<bool> addAccount(Account account) async {
    try {
      final token = await _storage.read(key: 'token');
      if (token == null) {
        throw Exception('Token not found');
      }

      _dio.options.headers['Authorization'] = 'Bearer $token';
      _dio.options.headers['Content-Type'] = 'application/json';

      final response = await _dio.post(
        '/register',
        data: jsonEncode({
          'userName': account.userName,
          'password': account.password,
          'email': account.email,
          'phoneNumber': account.phoneNumber,
          'address': account.address,
          // Không cần gửi các trường nullable như status, roleName, createDate, lastUpdateDate
        }),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        print('Response status: ${response.statusCode}');
        print('Response data: ${response.data}');
        return false;
      }
    } catch (e) {
      print('Exception: $e');
      throw Exception('Failed to add account: $e');
    }
  }

  // Lấy thông tin tài khoản theo ID
  Future<Account> getAccountById(int id) async {
    try {
      final token = await _storage.read(key: 'token');
      if (token == null) {
        throw Exception('Token not found');
      }

      _dio.options.headers['Authorization'] = 'Bearer $token';
      final response = await _dio.get('/accounts/$id');

      if (response.statusCode == 200) {
        return Account.fromJson(response.data);
      } else {
        throw Exception('Failed to load account');
      }
    } catch (e) {
      throw Exception('Failed to load account: $e');
    }
  }

  // Cập nhật thông tin tài khoản
  Future<bool> updateAccount(Account account) async {
    try {
      final token = await _storage.read(key: 'token');
      if (token == null) {
        throw Exception('Token not found');
      }

      _dio.options.headers['Authorization'] = 'Bearer $token';
      _dio.options.headers['Content-Type'] = 'application/json';
      final response = await _dio.put(
        '/api/AccountControllers/${account.accountID}',
        data: jsonEncode({
          'userName': account.userName,
          'password': account.password,
          'email': account.email,
          'phoneNumber': account.phoneNumber,
          'address': account.address,
          'status': true,
          'createDate': account.createDate != null ? account.createDate!.toIso8601String() : null,
          'lastUpdateDate': account.lastUpdateDate != null ? account.lastUpdateDate!.toIso8601String() : null,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      throw Exception('Failed to update account: $e');
    }
  }

  // Phương thức để trích xuất role từ token (giả sử bạn có cách để giải mã token)
  String _extractRoleFromToken(String token) {
    // Giả sử bạn có cách để giải mã token và trích xuất role (ví dụ: sử dụng jwt_decoder)
    // return JwtDecoder.decode(token)['role'] ?? '';
    return ''; // Thay thế bằng logic thực tế của bạn
  }
}
