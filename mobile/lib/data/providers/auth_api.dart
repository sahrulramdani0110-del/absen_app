import 'package:dio/dio.dart';
import 'api_provider.dart';

class AuthApi {
  final _dio = ApiProvider.dio;

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _dio.post('/api/auth/login', data: {
      'email': email,
      'password': password,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String role = 'member',
  }) async {
    final response = await _dio.post('/api/auth/register', data: {
      'name': name,
      'email': email,
      'password': password,
      'role': role,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> getProfile() async {
    final response = await _dio.get('/api/auth/profile');
    return response.data;
  }
}
