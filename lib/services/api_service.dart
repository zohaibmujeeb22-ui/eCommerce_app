import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/product.dart';

const String _apiBaseUrl = 'https://dummyjson.com';

String categoryLabel(String categorySlug) {
  return categorySlug
      .replaceAll('-', ' ')
      .split(' ')
      .map(
        (word) => word.isEmpty
            ? word
            : '${word[0].toUpperCase()}${word.substring(1)}',
      )
      .join(' ');
}

class ApiService {
  Future<List<Product>> fetchProducts() async {
    try {
      final response = await http.get(
        Uri.parse('$_apiBaseUrl/products?limit=100'),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final products = body['products'] as List<dynamic>;
        return products.map((e) => Product.fromJson(e)).toList();
      }

      throw Exception(
        'Failed to load products (status: ${response.statusCode})',
      );
    } catch (e, st) {
      debugPrint('ApiService.fetchProducts error: $e');
      debugPrint('$st');
      rethrow;
    }
  }

  Future<List<String>> fetchCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$_apiBaseUrl/products/categories'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          return data.map<String>((item) {
            if (item is String) {
              return item;
            }
            if (item is Map<String, dynamic>) {
              if (item.containsKey('slug')) {
                return item['slug'].toString();
              }
              if (item.containsKey('name')) {
                return item['name'].toString().toLowerCase().replaceAll(
                  ' ',
                  '-',
                );
              }
            }
            return item.toString();
          }).toList();
        }
      }

      throw Exception(
        'Failed to load categories (status: ${response.statusCode})',
      );
    } catch (e, st) {
      debugPrint('Error fetching categories: $e');
      debugPrint('$st');
      rethrow;
    }
  }

  Future<List<Product>> fetchByCategory(String category) async {
    final response = await http.get(
      Uri.parse('$_apiBaseUrl/products/category/$category'),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final products = body['products'] as List<dynamic>;
      return products.map((e) => Product.fromJson(e)).toList();
    }

    throw Exception(
      'Failed to load category products (status: ${response.statusCode})',
    );
  }

  Future<Product> fetchProductById(int id) async {
    final response = await http.get(Uri.parse('$_apiBaseUrl/products/$id'));

    if (response.statusCode == 200) {
      return Product.fromJson(jsonDecode(response.body));
    }

    throw Exception(
      'Failed to load product details (status: ${response.statusCode})',
    );
  }
}
