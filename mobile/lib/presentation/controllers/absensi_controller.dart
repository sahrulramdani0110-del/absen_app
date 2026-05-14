import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import '../../config/app_config.dart';
import '../../data/models/session_model.dart';
import '../../data/models/attendance_model.dart';
import '../../data/models/kelas_model.dart';
import '../../data/providers/api_provider.dart';
import '../../data/repositories/absensi_repository.dart';
import '../../data/repositories/kelas_repository.dart';

class AbsensiController extends GetxController {
  final _absensiRepo = Get.find<AbsensiRepository>();
  final _kelasRepo = Get.find<KelasRepository>();

  final sesiList = <SessionModel>[].obs;
  final kelasList = <KelasModel>[].obs;
  final riwayatList = <AttendanceModel>[].obs;

  final isLoading = false.obs;
  final isLocating = false.obs;
  final isSubmitting = false.obs;

  // Check-in state
  final currentLatitude = Rxn<double>();
  final currentLongitude = Rxn<double>();
  final selfieImagePath = RxnString();
  final selectedSession = Rxn<SessionModel>();

  @override
  void onInit() {
    super.onInit();
    fetchSesi();
    fetchKelas();
    fetchRiwayat();
  }

  Future<void> fetchSesi() async {
    try {
      isLoading.value = true;
      sesiList.value = await _absensiRepo.getSesi();
    } catch (e) {
      Get.snackbar('Error', ApiProvider.getErrorMessage(e), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchKelas() async {
    try {
      kelasList.value = await _kelasRepo.getKelas();
    } catch (_) {}
  }

  Future<void> fetchRiwayat() async {
    try {
      riwayatList.value = await _absensiRepo.getRiwayat();
    } catch (_) {}
  }

  // ── Platform-specific: GPS ──────────────────────────────
  Future<void> getLocation() async {
    try {
      isLocating.value = true;

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar('GPS Mati', 'Aktifkan GPS di pengaturan perangkat.', snackPosition: SnackPosition.BOTTOM);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Get.snackbar('Izin Ditolak', 'Izin lokasi diperlukan untuk absensi.', snackPosition: SnackPosition.BOTTOM);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        Get.snackbar('Izin Ditolak', 'Buka pengaturan untuk mengizinkan akses lokasi.', snackPosition: SnackPosition.BOTTOM);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      currentLatitude.value = position.latitude;
      currentLongitude.value = position.longitude;

      Get.snackbar('Berhasil', 'Lokasi berhasil didapat.', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Gagal mendapat lokasi: ${e.toString()}', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLocating.value = false;
    }
  }

  // ── Platform-specific: Kamera ──────────────────────────
  Future<void> takeSelfie() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
        maxWidth: 800,
      );

      if (image != null) {
        selfieImagePath.value = image.path;
        Get.snackbar('Berhasil', 'Foto selfie berhasil diambil.', snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal membuka kamera: ${e.toString()}', snackPosition: SnackPosition.BOTTOM);
    }
  }

  // ── Check-in ───────────────────────────────────────────
  Future<void> submitCheckIn(int sessionId) async {
    try {
      isSubmitting.value = true;

      final session = sesiList.firstWhereOrNull((s) => s.id == sessionId);

      if (session != null && session.hasLocation) {
        if (currentLatitude.value == null || currentLongitude.value == null) {
          Get.snackbar('Perlu Lokasi', 'Ambil lokasi GPS terlebih dahulu.', snackPosition: SnackPosition.BOTTOM);
          return;
        }
      }

      final result = await _absensiRepo.checkIn(
        sessionId: sessionId,
        latitude: currentLatitude.value,
        longitude: currentLongitude.value,
        photoUrl: selfieImagePath.value,
      );

      final status = result['status'] ?? 'hadir';
      Get.snackbar(
        'Absensi Berhasil! ✅',
        'Status kamu: $status',
        snackPosition: SnackPosition.BOTTOM,
      );

      // Reset state
      currentLatitude.value = null;
      currentLongitude.value = null;
      selfieImagePath.value = null;

      Get.back();
      fetchRiwayat();
    } catch (e) {
      Get.snackbar('Gagal Absen', ApiProvider.getErrorMessage(e), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> tutupSesi(int sessionId) async {
    try {
      await _absensiRepo.tutupSesi(sessionId);
      Get.snackbar('Berhasil', 'Sesi absensi ditutup.', snackPosition: SnackPosition.BOTTOM);
      fetchSesi();
    } catch (e) {
      Get.snackbar('Error', ApiProvider.getErrorMessage(e), snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> bukaSesi({
    required int kelasId,
    required String title,
    required String startTime,
    double? latitude,
    double? longitude,
    int radiusMeters = 100,
  }) async {
    try {
      await _absensiRepo.bukaSesi(
        kelasId: kelasId,
        title: title,
        startTime: startTime,
        latitude: latitude,
        longitude: longitude,
        radiusMeters: radiusMeters,
      );
      fetchSesi();
    } catch (e) {
      rethrow;
    }
  }

  List<SessionModel> get sesiAktif => sesiList.where((s) => s.isOpen).toList();
  List<SessionModel> get sesiTutup => sesiList.where((s) => !s.isOpen).toList();

  int get totalHadir => riwayatList.where((r) => r.status == 'hadir').length;
  int get totalTerlambat => riwayatList.where((r) => r.status == 'terlambat').length;
  int get persentaseHadir {
    if (riwayatList.isEmpty) return 0;
    return ((totalHadir + totalTerlambat) / riwayatList.length * 100).round();
  }
}
