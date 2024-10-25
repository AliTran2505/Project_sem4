import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';

class OrderService {
  final String _baseUrl = "http://art.somee.com/api";
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  Future<bool> placeOrder(List<int> cartIds) async {
    String? token = await _storage.read(key: 'token');
    if (token == null) {
      throw Exception('User not logged in');
    }
     try {
      final response = await Dio().delete(
        '$_baseUrl/Carts/DeleteMultiple',
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        }),
        data: cartIds // Gửi danh sách cartId
      );

      if ((response.statusCode ?? 0) >= 200 && (response.statusCode ?? 0) < 210) {
        return true; // Xóa thành công
      } else if (response.statusCode == 401) {
        throw Exception('Token expired or invalid. Please log in again.');
      } else {
        throw Exception('Failed to delete products');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to delete products: $e');
    }
  }
}
