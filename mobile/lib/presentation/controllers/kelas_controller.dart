import 'package:get/get.dart';
import '../../data/models/kelas_model.dart';
import '../../data/providers/api_provider.dart';
import '../../data/repositories/kelas_repository.dart';

class KelasController extends GetxController {
  final _repository = Get.find<KelasRepository>();

  final kelasList = <KelasModel>[].obs;
  final anggotaMap = <int, List<dynamic>>{}.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchKelas();
  }

  Future<void> fetchKelas() async {
    try {
      isLoading.value = true;
      kelasList.value = await _repository.getKelas();
    } catch (e) {
      Get.snackbar('Error', ApiProvider.getErrorMessage(e), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchAnggota(int kelasId) async {
    try {
      final data = await _repository.getAnggota(kelasId);
      anggotaMap[kelasId] = data;
      anggotaMap.refresh();
    } catch (e) {
      Get.snackbar('Error', ApiProvider.getErrorMessage(e), snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> tambahAnggota({
    required int kelasId,
    required int userId,
    String role = 'member',
  }) async {
    try {
      await _repository.tambahAnggota(kelasId: kelasId, userId: userId, role: role);
      Get.snackbar('Berhasil', 'Anggota berhasil ditambahkan.', snackPosition: SnackPosition.BOTTOM);
      fetchAnggota(kelasId);
    } catch (e) {
      Get.snackbar('Error', ApiProvider.getErrorMessage(e), snackPosition: SnackPosition.BOTTOM);
    }
  }
}
