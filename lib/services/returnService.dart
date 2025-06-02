import 'package:ass_sisforas/models/returnModel.dart';
import 'package:ass_sisforas/tokens/storageToken.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ReturnService {
  static const String _baseUrl = 'http://127.0.0.1:8000/api';

  Future<List<ReturnModel>> getReturns() async {
    final _token = await StorageToken.getToken();
    final userId = await StorageToken.getUserId();
    final response = await http.get(
      Uri.parse('$_baseUrl/returns/$userId'),
      headers: {'Authorization': 'Bearer $_token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body)['dataReturn'];
      return data.map((json) => ReturnModel.fromJson(json)).toList();
    } else {
      throw Exception('Get returns failed');
    }
  }

  Future<int> getReturnCount() async {
    final _token = await StorageToken.getToken();
    final userId = await StorageToken.getUserId();
    final response = await http.get(
      Uri.parse('$_baseUrl/returns/count/$userId'),
      headers: {'Authorization': 'Bearer $_token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['returnCount'];
      return data;
    } else {
      throw Exception('Get returns count failed');
    }
  }

  Future<ReturnModel> addReturn(ReturnModel returnModel) async {
    final _token = await StorageToken.getToken();
    final response = await http.post(
      Uri.parse('$_baseUrl/returns'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
      body: jsonEncode(returnModel.toJson()),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['dataReturn'];
      return ReturnModel.fromJson(data);
    } else {
      throw Exception('Add return failed');
    }
  }
}
