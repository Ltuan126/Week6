import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ApiService {
  // Thay URL này bằng URL API thực tế của bạn
  static const String url = 'https://your-api-url.com/api';

  // Timeout cho request
  static const Duration timeout = Duration(seconds: 30);

  // GET - Lấy danh sách tất cả products
  Future<List<Product>> fetchProducts() async {
    try {
      final response = await http
          .get(
            Uri.parse('$url/products'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        // Parse JSON
        List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching products: $e');
    }
  }

  // GET - Lấy theo ID
  Future<Product> fetchProductById(String id) async {
    try {
      final response = await http
          .get(
            Uri.parse('$url/products/$id'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        return Product.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load product: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching product: $e');
    }
  }
}