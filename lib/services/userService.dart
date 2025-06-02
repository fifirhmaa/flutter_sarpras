import 'package:ass_sisforas/models/categoryModel.dart';
import 'package:ass_sisforas/models/itemModel.dart';
import 'package:ass_sisforas/models/userModel.dart';
import 'package:http/http.dart' as http;
import 'package:ass_sisforas/tokens/storageToken.dart';
import 'dart:convert';

class UserService {
  static const String _baseUrl = 'http://127.0.0.1:8000/api';

  Future<UserModel> getUser() async {
    final token = await StorageToken.getToken();

    final response = await http.get(
      Uri.parse('$_baseUrl/me'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return UserModel.fromJson(data);
    } else {
      throw Exception('Get user failed');
    }
  }

  Future<List<ItemModel>> getItems() async {
    final token = await StorageToken.getToken();

    final response = await http.get(
      Uri.parse('$_baseUrl/items'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final List itemsJson = jsonData['data'];

      return itemsJson.map((item) => ItemModel.fromJson(item)).toList();
    } else {
      throw Exception('Get items failed');
    }
  }

  Future<List<CategoryModel>> getCategories() async {
    final token = await StorageToken.getToken();

    final response = await http.get(
      Uri.parse('$_baseUrl/categories'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final List categoriesJson = jsonData['data'];

      return categoriesJson
          .map((json) => CategoryModel.fromJson(json))
          .toList();
    } else {
      throw Exception('Get categories failed');
    }
  }

  Future<int> getItemCount() async {
    final token = await StorageToken.getToken();

    final response = await http.get(
      Uri.parse('$_baseUrl/items/count'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return jsonData['itemCount'];
    } else {
      throw Exception('Get categories failed');
    }
  }
}
