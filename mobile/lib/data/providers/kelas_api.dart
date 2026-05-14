import 'api_provider.dart';

class KelasApi {
  final _dio = ApiProvider.dio;

  Future<List<dynamic>> getKelas() async {
    final response = await _dio.get('/api/kelas');
    return response.data;
  }

  Future<Map<String, dynamic>> buatKelas({
    required int orgId,
    required String name,
    String? description,
  }) async {
    final response = await _dio.post('/api/kelas', data: {
      'org_id': orgId,
      'name': name,
      'description': ?description,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> getAnggota(int kelasId) async {
    final response = await _dio.get('/api/kelas/$kelasId/anggota');
    return response.data;
  }

  Future<Map<String, dynamic>> tambahAnggota({
    required int kelasId,
    required int userId,
    String role = 'member',
  }) async {
    final response = await _dio.post('/api/kelas/$kelasId/anggota', data: {
      'user_id': userId,
      'role': role,
    });
    return response.data;
  }
}
