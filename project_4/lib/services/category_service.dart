import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:project_4/models/category.dart';

class CategoryService {
  static const String _baseUrl = 'http://art.somee.com/api';

  // lấy tất cả danh mục
  static Future<List<Category>> getAll() async {
    final response = await http.get(
      Uri.parse(_baseUrl + "/Categories"),
      headers: {
        'Content-Type': 'application/json',
        'Charset': 'utf-8'
      },
    );
    if (response.statusCode == 200) {
      try {
        final List<dynamic> jsonList = jsonDecode(response.body) as List<dynamic>;
        return Category.listFromJson(jsonList);
      } catch (e) {
        throw Exception('Failed to parse JSON: $e');
      }
    } else {
      throw Exception('Failed to load categories: ${response.body}');
    }
  }
}
