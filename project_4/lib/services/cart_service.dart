import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';

class CartService {
  static const String _baseUrl = 'http://art.somee.com/api';
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  // Thêm sản phẩm vào giỏ hàng
  Future<void> addProductToCart(int productId, int quantity) async {
    String? token = await _storage.read(key: 'token');
    if (token == null) {
      throw Exception('User not logged in');
    }

    final response = await Dio().post(
      '$_baseUrl/Carts/AddProductToCart',
      options: Options(headers: {
        'Authorization': 'Bearer $token',
      }),
      data: {
        'productId': productId,
        'quantity': quantity,
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to add product to cart');
    }
  }

  // Lấy giỏ hàng
  Future<List<dynamic>> getCartByAccount() async {
    String? token = await _storage.read(key: 'token');
    if (token == null) {
      throw Exception('User not logged in');
    }

    final response = await Dio().get(
      '$_baseUrl/Carts/GetCartByAccount',
      options: Options(headers: {
        'Authorization': 'Bearer $token',
      }),
    );

    if (response.statusCode == 200) {
      return response.data;
    } else if (response.statusCode == 401) {
      // Token hết hạn hoặc không hợp lệ
      throw Exception('Token expired or invalid. Please log in again.');
    } else {
      throw Exception('Failed to load cart');
    }
  }

  // Xóa sản phẩm khỏi giỏ hàng
  Future<bool> deleteProductFromCart(int cartId) async {
    String? token = await _storage.read(key: 'token');
    if (token == null) {
      throw Exception('User not logged in');
    }
    try {
      final response = await Dio().delete(
        '$_baseUrl/Carts/$cartId',
        options: Options(headers: {
          'Authorization': 'Bearer $token',
        }),
      );

      if ((response.statusCode ?? 0) >= 200 && (response.statusCode ?? 0) < 210) {
        return true; // Xóa thành công
      } else if (response.statusCode == 401) {
        throw Exception('Token expired or invalid. Please log in again.');
      } else {
        throw Exception('Failed to delete product');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to delete product: $e');
    }
  }

  // xóa nhiều sản phẩm
  Future<bool> deleteMultipleProductsFromCart( List<int> cartIds) async {
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

   // Cập nhật giỏ hàng
  Future<void> updateCart(int cartId, String type) async {
    String? token = await _storage.read(key: 'token');
    if (token == null) {
      throw Exception('User not logged in');
    }
    try {
      final response = await Dio().put(
        '$_baseUrl/Carts/$cartId?type=$type',
        options: Options(headers: {
          'Authorization': 'Bearer <your_token>',
          'Content-Type': 'application/json',
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update cart item');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to update cart item: $e');
    }
  }

}