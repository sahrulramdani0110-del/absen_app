import '../models/session_model.dart';
import '../models/attendance_model.dart';
import '../providers/absensi_api.dart';

class AbsensiRepository {
  final _api = AbsensiApi();

  Future<List<SessionModel>> getSesi({int? kelasId}) async {
    final data = await _api.getSesi(kelasId: kelasId);
    return data.map((e) => SessionModel.fromJson(e)).toList();
  }

  Future<Map<String, dynamic>> bukaSesi({
    required int kelasId,
    required String title,
    required String startTime,
    double? latitude,
    double? longitude,
    int radiusMeters = 100,
  }) async {
    return await _api.bukaSesi(
      kelasId: kelasId,
      title: title,
      startTime: startTime,
      latitude: latitude,
      longitude: longitude,
      radiusMeters: radiusMeters,
    );
  }

  Future<void> tutupSesi(int sessionId) async {
    await _api.tutupSesi(sessionId);
  }

  Future<Map<String, dynamic>> checkIn({
    required int sessionId,
    double? latitude,
    double? longitude,
    String? photoUrl,
  }) async {
    return await _api.checkIn(
      sessionId: sessionId,
      latitude: latitude,
      longitude: longitude,
      photoUrl: photoUrl,
      deviceType: 'mobile',
    );
  }

  Future<Map<String, dynamic>> getRekapSesi(int sessionId) async {
    return await _api.getRekapSesi(sessionId);
  }

  Future<List<AttendanceModel>> getRiwayat() async {
    final data = await _api.getRiwayat();
    final list = data['data'] as List;
    return list.map((e) => AttendanceModel.fromJson(e)).toList();
  }
}
