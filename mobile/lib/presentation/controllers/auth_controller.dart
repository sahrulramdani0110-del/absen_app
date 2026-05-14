import 'package:get/get.dart';
import '../../config/app_config.dart';
import '../../data/models/user_model.dart';
import '../../data/providers/api_provider.dart';
import '../../data/repositories/auth_repository.dart';

class AuthController extends GetxController {
  final _repository = Get.find<AuthRepository>();

  final isLoading = false.obs;
  final user = Rxn<UserModel>();

  @override
  void onInit() {
    super.onInit();
    user.value = _repository.getStoredUser();
  }

  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      final result = await _repository.login(email, password);
      user.value = result['user'] as UserModel;
      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      Get.snackbar(
        'Login Gagal',
        ApiProvider.getErrorMessage(e),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    String role = 'member',
  }) async {
    try {
      isLoading.value = true;
      await _repository.register(name: name, email: email, password: password, role: role);
      Get.snackbar('Berhasil', 'Registrasi berhasil! Silakan login.', snackPosition: SnackPosition.BOTTOM);
      Get.offNamed(AppRoutes.login);
    } catch (e) {
      Get.snackbar('Registrasi Gagal', ApiProvider.getErrorMessage(e), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    user.value = null;
    Get.offAllNamed(AppRoutes.login);
  }

  bool get isAdmin => user.value?.isAdmin ?? false;
}
