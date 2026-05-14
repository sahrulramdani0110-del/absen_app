import 'api_provider.dart';

class AbsensiApi {
  final _dio = ApiProvider.dio;

  Future<List<dynamic>> getSesi({int? kelasId}) async {
    final response = await _dio.get(
      '/api/absensi/sesi',
      queryParameters: kelasId != null ? {'kelas_id': kelasId} : null,
    );
    return response.data;
  }

  Future<Map<String, dynamic>> bukaSesi({
    required int kelasId,
    required String title,
    required String startTime,
    double? latitude,
    double? longitude,
    int radiusMeters = 100,
  }) async {
    final response = await _dio.post('/api/absensi/sesi', data: {
      'kelas_id': kelasId,
      'title': title,
      'start_time': startTime,
      'latitude': ?latitude,
      'longitude': ?longitude,
      'radius_meters': radiusMeters,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> tutupSesi(int sessionId) async {
    final response = await _dio.patch('/api/absensi/sesi/$sessionId/tutup');
    return response.data;
  }

  Future<Map<String, dynamic>> checkIn({
    required int sessionId,
    double? latitude,
    double? longitude,
    String? photoUrl,
    String deviceType = 'mobile',
  }) async {
    final response = await _dio.post('/api/absensi/checkin', data: {
      'session_id': sessionId,
      'latitude': ?latitude,
      'longitude': ?longitude,
      'photo_url': ?photoUrl,
      'device_type': deviceType,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> getRekapSesi(int sessionId) async {
    final response = await _dio.get('/api/absensi/sesi/$sessionId/rekap');
    return response.data;
  }

  Future<Map<String, dynamic>> getRiwayat() async {
    final response = await _dio.get('/api/absensi/riwayat');
    return response.data;
  }
}
