import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/app_config.dart';
import '../../../presentation/themes/app_theme.dart';
import '../../../presentation/controllers/absensi_controller.dart';
import '../../../presentation/controllers/auth_controller.dart';
import '../../../presentation/widgets/common_widgets.dart';
import '../../../data/models/session_model.dart';

class AbsensiScreen extends StatelessWidget {
  const AbsensiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AbsensiController>();
    final auth = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        title: const Text('Absensi'),
        actions: [
          Obx(() => auth.isAdmin
              ? IconButton(
                  onPressed: () => _showBukaSesiDialog(ctrl),
                  icon: const Icon(Icons.add_circle_rounded, color: AppColors.primary),
                )
              : const SizedBox()),
        ],
      ),
      body: Obx(() {
        if (ctrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (ctrl.sesiList.isEmpty) {
          return const EmptyState(icon: Icons.event_busy_rounded, message: 'Belum ada sesi absensi');
        }
        return RefreshIndicator(
          onRefresh: ctrl.fetchSesi,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (ctrl.sesiAktif.isNotEmpty) ...[
                const SectionHeader(title: 'Sesi Aktif'),
                const SizedBox(height: 10),
                ...ctrl.sesiAktif.map((s) => _SesiCard(sesi: s, ctrl: ctrl, auth: auth)),
              ],
              if (ctrl.sesiTutup.isNotEmpty) ...[
                const SizedBox(height: 20),
                const SectionHeader(title: 'Sesi Selesai'),
                const SizedBox(height: 10),
                ...ctrl.sesiTutup.map((s) => _SesiCard(sesi: s, ctrl: ctrl, auth: auth)),
              ],
            ],
          ),
        );
      }),
    );
  }

  void _showBukaSesiDialog(AbsensiController ctrl) {
    final titleCtrl = TextEditingController();
    final radiusCtrl = TextEditingController(text: '100');
    String? selectedKelasId;
    DateTime selectedTime = DateTime.now();

    Get.dialog(
      StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Buka Sesi Absensi', style: TextStyle(fontWeight: FontWeight.w700)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Pilih kelas
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Kelas',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: ctrl.kelasList.map((k) => DropdownMenuItem(value: k.id.toString(), child: Text(k.name))).toList(),
                  onChanged: (val) => selectedKelasId = val,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: titleCtrl,
                  decoration: InputDecoration(
                    labelText: 'Judul Sesi',
                    hintText: 'cth: Absensi Senin Pagi',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: radiusCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Radius (meter)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                // GPS button
                Obx(() => OutlinedButton.icon(
                      onPressed: ctrl.isLocating.value ? null : () => ctrl.getLocation(),
                      icon: const Icon(Icons.my_location_rounded, size: 18),
                      label: Text(ctrl.isLocating.value
                          ? 'Mendapat lokasi...'
                          : ctrl.currentLatitude.value != null
                              ? '${ctrl.currentLatitude.value!.toStringAsFixed(4)}, ${ctrl.currentLongitude.value!.toStringAsFixed(4)}'
                              : 'Gunakan Lokasi Saat Ini'),
                      style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    )),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () async {
                if (selectedKelasId == null || titleCtrl.text.isEmpty) {
                  Get.snackbar('Error', 'Kelas dan judul wajib diisi', snackPosition: SnackPosition.BOTTOM);
                  return;
                }
                Get.back();
                try {
                  await ctrl._absensiRepo.bukaSesi(
                    kelasId: int.parse(selectedKelasId!),
                    title: titleCtrl.text,
                    startTime: DateTime.now().toIso8601String(),
                    latitude: ctrl.currentLatitude.value,
                    longitude: ctrl.currentLongitude.value,
                    radiusMeters: int.tryParse(radiusCtrl.text) ?? 100,
                  );
                  Get.snackbar('Berhasil', 'Sesi absensi dibuka!', snackPosition: SnackPosition.BOTTOM);
                  ctrl.fetchSesi();
                } catch (e) {
                  Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
                }
              },
              child: const Text('Buka Sesi'),
            ),
          ],
        );
      }),
    );
  }
}

class _SesiCard extends StatelessWidget {
  final SessionModel sesi;
  final AbsensiController ctrl;
  final AuthController auth;

  const _SesiCard({required this.sesi, required this.ctrl, required this.auth});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.ink.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(sesi.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.ink)),
              ),
              StatusBadge(status: sesi.status == 'open' ? 'open' : 'closed'),
            ],
          ),
          const SizedBox(height: 4),
          Text(sesi.kelasName ?? '-', style: const TextStyle(color: AppColors.inkMuted, fontSize: 12)),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.schedule, size: 13, color: AppColors.inkMuted),
              const SizedBox(width: 4),
              Text(
                '${sesi.startTime.day}/${sesi.startTime.month}/${sesi.startTime.year} ${sesi.startTime.hour.toString().padLeft(2, '0')}:${sesi.startTime.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(color: AppColors.inkMuted, fontSize: 12),
              ),
              if (sesi.hasLocation) ...[
                const SizedBox(width: 12),
                const Icon(Icons.location_on, size: 13, color: AppColors.inkMuted),
                const SizedBox(width: 4),
                Text('GPS aktif · ${sesi.radiusMeters.round()}m', style: const TextStyle(color: AppColors.inkMuted, fontSize: 12)),
              ],
            ],
          ),
          if (sesi.isOpen) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Get.toNamed(AppRoutes.checkin, arguments: sesi),
                    icon: const Icon(Icons.fingerprint_rounded, size: 18),
                    label: const Text('Absen Sekarang'),
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 10)),
                  ),
                ),
                if (auth.isAdmin) ...[
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () => ctrl.tutupSesi(sesi.id),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      side: BorderSide(color: AppColors.danger.withOpacity(0.4)),
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    ),
                    child: const Text('Tutup'),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}
