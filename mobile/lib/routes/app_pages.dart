import 'package:get/get.dart';
import '../config/app_config.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/absensi_repository.dart';
import '../data/repositories/kelas_repository.dart';
import '../presentation/controllers/auth_controller.dart';
import '../presentation/controllers/absensi_controller.dart';
import '../presentation/controllers/kelas_controller.dart';
import '../presentation/screens/splash/splash_screen.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/auth/register_screen.dart';
import '../presentation/screens/home/home_screen.dart';
import '../presentation/screens/absensi/absensi_screen.dart';
import '../presentation/screens/absensi/checkin_screen.dart';
import '../presentation/screens/kelas/kelas_screen.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
      binding: BindingsBuilder(() {
        Get.put(AuthRepository());
        Get.put(AuthController());
      }),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterScreen(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeScreen(),
      binding: BindingsBuilder(() {
        Get.put(AbsensiRepository());
        Get.put(KelasRepository());
        Get.put(AbsensiController());
      }),
    ),
    GetPage(
      name: AppRoutes.absensi,
      page: () => const AbsensiScreen(),
    ),
    GetPage(
      name: AppRoutes.checkin,
      page: () => const CheckinScreen(),
    ),
    GetPage(
      name: AppRoutes.kelas,
      page: () => const KelasScreen(),
      binding: BindingsBuilder(() {
        Get.put(KelasRepository());
        Get.put(KelasController());
      }),
    ),
  ];
}
