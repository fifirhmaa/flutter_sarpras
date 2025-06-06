import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class StorageToken {
  static Future<void> saveToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  static Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<void> deleteToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  static Future<String?> getId() async {
    String? token = await StorageToken.getToken();
    if (token != null) {
      Map<String, dynamic> decodedToken = jsonDecode(token);
      return decodedToken['data']['id'].toString();
    }
    return null;
  }

  static Future<void> saveUser(Map<String, dynamic> userData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print("user data: ${jsonEncode(userData)}");
    await prefs.setString('user', jsonEncode(userData));
  }

  static Future<String?> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userData = prefs.getString('user');
    if (userData != null) {
      try {
        Map<String, dynamic> decodedUserData = jsonDecode(userData);
        return decodedUserData['id'].toString();
      } catch (e) {
        print('Error decoding user data: $e');
        return null;
      }
    }
    return null;
  }

  static Future<void> deleteUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
  }

  // static Future<void> removeToken() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   await prefs.remove('token');
  // }
}
