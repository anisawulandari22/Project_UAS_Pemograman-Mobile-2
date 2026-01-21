import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';

class ApiService {
  final String baseUrl = "https://6944c4267dd335f4c3612634.mockapi.io"; 

  Future<List<Product>> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/products'));
      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        return data.map((item) => Product.fromJson(item)).toList();
      } else {
        debugPrint("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error Fetching: $e");
    }
    return [];
  }

  Future<bool> addProduct(Map<String, dynamic> product) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/products'),
        headers: {"Content-Type": "application/json"},
        body: json.encode(product),
      );
      return response.statusCode == 201;
    } catch (e) {
      debugPrint("Error Adding: $e");
      return false;
    }
  }

  Future<bool> updateProduct(String id, Map<String, dynamic> product) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/products/$id'),
        headers: {"Content-Type": "application/json"},
        body: json.encode(product),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Error Update: $e");
      return false;
    }
  }

  Future<bool> deleteProduct(String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/products/$id'));
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Error Delete: $e");
      return false;
    }
  }
}
