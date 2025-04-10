import 'dart:convert';
import 'package:battleships/common/end_points.dart';
import 'package:http/http.dart' as http;

import '../models/auth_response.dart';

class AuthService {
  Future<AuthResponse> registerUser(String username, String password) async {
    final response = await http.post(
      Uri.parse('${EndPoints.baseUrl}/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return AuthResponse.fromJson(data);
    } else {
      throw Exception('Registration failed');
    }
  }

  Future<AuthResponse> loginUser(String username, String password) async {
    final response = await http.post(
      Uri.parse('${EndPoints.baseUrl}/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return AuthResponse.fromJson(data);
    } else {
      throw Exception('Login failed');
    }
  }
}
