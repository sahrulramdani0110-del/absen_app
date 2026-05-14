import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../presentation/themes/app_theme.dart';
import '../../../presentation/controllers/auth_controller.dart';
import '../../../presentation/controllers/absensi_controller.dart';
import '../../../presentation/widgets/common_widgets.dart';
import '../../../config/app_config.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final absensi = Get.find<AbsensiController>();

    return Scaffold(
      backgroundColor: AppColors.paper,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await absensi.fetchSesi();
            await absensi.fetchRiwayat();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Obx(() => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Halo, ${auth.user.value?.name.split(' ').first ?? ''} 👋',
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.ink),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const Text(
                                'Ringkasan kehadiran kamu',
                                style: TextStyle(color: AppColors.inkMuted, fontSize: 13),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          )),
                    ),
                    const SizedBox(width: 12),
                    // Logout button
                    IconButton(
                      onPressed: () => _showLogoutDialog(auth),
                      icon: const Icon(Icons.logout_rounded, color: AppColors.inkMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Stats grid
                Obx(() => GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.4,
                      children: [
                        _StatCard(
                          label: 'Total Absensi',
                          value: '${absensi.riwayatList.length}',
                          icon: Icons.calendar_today_rounded,
                          color: AppColors.primary,
                          bgColor: AppColors.primarySoft,
                        ),
                        _StatCard(
                          label: 'Hadir',
                          value: '${absensi.totalHadir}',
                          icon: Icons.check_circle_rounded,
                          color: AppColors.success,
                          bgColor: AppColors.success.withOpacity(0.1),
                        ),
                        _StatCard(
                          label: 'Terlambat',
                          value: '${absensi.totalTerlambat}',
                          icon: Icons.schedule_rounded,
                          color: AppColors.warning,
                          bgColor: AppColors.warning.withOpacity(0.1),
                        ),
                        _StatCard(
                          label: 'Sesi Aktif',
                          value: '${absensi.sesiAktif.length}',
                          icon: Icons.live_tv_rounded,
                          color: AppColors.inkSoft,
                          bgColor: AppColors.ink.withOpacity(0.06),
                        ),
                      ],
                    )),
                const SizedBox(height: 24),

                // Kehadiran bar
                Obx(() {
                  final persen = absensi.persentaseHadir;
                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.ink.withOpacity(0.06)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Tingkat Kehadiran', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.ink)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Text('$persen%', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.ink)),
                            const SizedBox(width: 8),
                            Text('dari ${absensi.riwayatList.length} sesi', style: const TextStyle(color: AppColors.inkMuted, fontSize: 13)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: persen / 100,
                            backgroundColor: AppColors.ink.withOpacity(0.06),
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                            minHeight: 10,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 24),

                // Riwayat terbaru
                const SectionHeader(title: 'Riwayat Terbaru'),
                const SizedBox(height: 12),
                Obx(() {
                  if (absensi.riwayatList.isEmpty) {
                    return const EmptyState(icon: Icons.history_rounded, message: 'Belum ada riwayat absensi');
                  }
                  return Column(
                    children: absensi.riwayatList.take(5).map((r) => Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.ink.withOpacity(0.06)),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(r.sessionTitle ?? '-', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.ink)),
                                    const SizedBox(height: 2),
                                    Text(r.kelasName ?? '-', style: const TextStyle(color: AppColors.inkMuted, fontSize: 12)),
                                  ],
                                ),
                              ),
                              StatusBadge(status: r.status),
                            ],
                          ),
                        )).toList(),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(AuthController auth) {
    Get.dialog(AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Keluar', style: TextStyle(fontWeight: FontWeight.w700)),
      content: const Text('Yakin ingin keluar dari akun?'),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
        TextButton(onPressed: () { Get.back(); auth.logout(); }, child: const Text('Keluar', style: TextStyle(color: AppColors.danger))),
      ],
    ));
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color bgColor;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.ink.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 18),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.ink),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: AppColors.inkMuted),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
