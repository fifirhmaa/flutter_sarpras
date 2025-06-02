import 'dart:typed_data';

import 'package:ass_sisforas/models/borrowModel.dart';
import 'package:http/http.dart' as http;
import 'package:ass_sisforas/tokens/storageToken.dart';
import 'dart:convert';

class BorrowService {
  static const String _baseUrl = 'http://127.0.0.1:8000/api';

  Future<int> getBorrowCount() async {
    final token = await StorageToken.getToken();
    final userId = await StorageToken.getUserId();

    if (userId == null) throw Exception('User ID not found');

    final response = await http.get(
      Uri.parse('$_baseUrl/borrows/count/$userId'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode} - ${response.body}');
    }

    try {
      final data = jsonDecode(response.body.trim());
      return data['borrowCount'];
    } catch (e) {
      throw FormatException('Invalid JSON: ${response.body}');
    }
  }

  Future<int> getFineCount() async {
    final token = await StorageToken.getToken();
    final userId = await StorageToken.getUserId();

    if (userId == null) throw Exception('User ID not found');

    final response = await http.get(
      Uri.parse('$_baseUrl/borrows/fine/$userId'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    try {
      final data = jsonDecode(response.body.trim());
      return data['fineCount'];
    } catch (e) {
      throw FormatException('Invalid JSON: ${response.body}');
    }
  }

  Future<List<Borrow>> getBorrows() async {
    final token = await StorageToken.getToken();
    final userId = await StorageToken.getUserId();

    if (userId == null) throw Exception('User ID not found');

    final response = await http.get(
      Uri.parse('$_baseUrl/borrows/$userId'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    try {
      final data = jsonDecode(response.body.trim());
      return data['dataBorrow']
          .map<Borrow>((json) => Borrow.fromJson(json))
          .toList();
    } catch (e) {
      throw FormatException('Invalid JSON: ${response.body}');
    }
  }

  Future<Borrow> addBorrow(Borrow borrow) async {
    final token = await StorageToken.getToken();

    final response = await http.post(
      Uri.parse('$_baseUrl/borrows'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(borrow.toJson()),
    );

    final responseData = jsonDecode(response.body);
    return Borrow.fromJson(responseData);
  }

  Future<Uint8List> reportBorrow(Borrow borrow) async {
    final token = await StorageToken.getToken();

    final response = await http.post(
      Uri.parse('$_baseUrl/reports/borrows'),
      headers: {
        'Accept': 'application/pdf',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(borrow.toJson()),
    );

    return response.bodyBytes;
  }
}
