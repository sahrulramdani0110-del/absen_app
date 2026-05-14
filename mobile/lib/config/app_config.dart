class AppConfig {
  // Ganti dengan IP lokal kamu saat development
  // cth: 'http://192.168.1.100:3000'
  static const String baseUrl = 'http://10.0.2.2:3000'; // 10.0.2.2 = localhost di Android emulator

  static const String appName = 'AbsensiKu';
  static const String appVersion = '1.0.0';

  // Waktu toleransi terlambat (menit)
  static const int toleransiMenit = 15;
}

class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String absensi = '/absensi';
  static const String checkin = '/checkin';
  static const String rekap = '/rekap';
  static const String kelas = '/kelas';
  static const String profile = '/profile';
}
