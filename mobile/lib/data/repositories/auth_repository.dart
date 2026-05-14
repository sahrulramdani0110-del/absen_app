import 'package:get_storage/get_storage.dart';
import '../models/user_model.dart';
import '../providers/auth_api.dart';

class AuthRepository {
  final _api = AuthApi();
  final _storage = GetStorage();

  Future<Map<String, dynamic>> login(String email, String password) async {
    final data = await _api.login(email, password);
    final token = data['token'] as String;
    final user = UserModel.fromJson(data['user']);

    await _storage.write('token', token);
    await _storage.write('user', user.toJson());

    return {'token': token, 'user': user};
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    String role = 'member',
  }) async {
    await _api.register(name: name, email: email, password: password, role: role);
  }

  Future<void> logout() async {
    await _storage.erase();
  }

  UserModel? getStoredUser() {
    final userData = _storage.read<Map<String, dynamic>>('user');
    if (userData == null) return null;
    return UserModel.fromJson(userData);
  }

  String? getToken() => _storage.read<String>('token');

  bool get isLoggedIn => getToken() != null;
}
