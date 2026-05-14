import '../models/kelas_model.dart';
import '../providers/kelas_api.dart';

class KelasRepository {
  final _api = KelasApi();

  Future<List<KelasModel>> getKelas() async {
    final data = await _api.getKelas();
    return data.map((e) => KelasModel.fromJson(e)).toList();
  }

  Future<void> buatKelas({
    required int orgId,
    required String name,
    String? description,
  }) async {
    await _api.buatKelas(orgId: orgId, name: name, description: description);
  }

  Future<List<dynamic>> getAnggota(int kelasId) async {
    final data = await _api.getAnggota(kelasId);
    return data['data'] ?? [];
  }

  Future<void> tambahAnggota({
    required int kelasId,
    required int userId,
    String role = 'member',
  }) async {
    await _api.tambahAnggota(kelasId: kelasId, userId: userId, role: role);
  }
}
