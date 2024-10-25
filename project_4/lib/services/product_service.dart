import 'package:http/http.dart' as http;
import 'package:project_4/models/product.dart';
import 'dart:convert';

class ProductService {
  static const String _baseUrl = 'http://art.somee.com/api';

  // lấy tất cả sản phẩm
  static Future<List<Product>> getAll() async {
    final response = await http.get(Uri.parse("$_baseUrl/Products"));
    final List<dynamic> jsonList = jsonDecode(response.body) as List<dynamic>;
    return Product.listFromJson(jsonList);
  }

  // lấy sản phẩm theo id
  static Future<Product?> getById(int id) async {
    final response = await http.get(Uri.parse('$_baseUrl/Products/$id'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Product.fromJson(data);
    } else {
      throw Exception('Failed to load product');
    }
  }

  // lấy sản phẩm theo categoryId
  Future<List<Product>> getProductsByCategoryId(int categoryId) async {
    print("Received categoryId in ProductService: $categoryId");
    final response = await http.get(
      Uri.parse('$_baseUrl/Products/filterByCategory?categoryId=$categoryId'),
      headers: {'Content-Type': 'application/json', 'Charset': 'utf-8'},
    );
    if (response.statusCode == 200 || response.statusCode == 204) {
      final List<dynamic> jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((data) => Product.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }

  // tìm kiếm theo tên sản phẩm
  Future<List<Product>> searchProducts(String name) async {
    final response =
        await http.get(Uri.parse('$_baseUrl/Products/searchByName?name=$name'));
    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);
      return jsonData
          .map((data) => Product.fromJson(data))
          .toList()
          .cast<Product>();
    } else {
      return [];
    }
  }
}
