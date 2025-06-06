import 'package:http/http.dart' as http;
import 'package:ass_sisforas/tokens/storageToken.dart';
import 'dart:convert';

class Authservice {
  static const String _baseUrl = 'http://127.0.0.1:8000/api';

  Future<void> login(String email, String password) async {
    final response = await http.post(Uri.parse('$_baseUrl/login'), body: {
      'email': email,
      'password': password,
    });

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final accessToken = json['access_token'];
      final userData = json['data'];

      print('Login response: ${response.body}');

      await StorageToken.saveToken(accessToken);

      print("user data: ${userData}");
      await StorageToken.saveUser(userData);
    } else {
      throw Exception('Login failed');
    }
  }

  Future<void> logout() async {
    await StorageToken.deleteToken();
    await StorageToken.deleteUser();
  }
}
