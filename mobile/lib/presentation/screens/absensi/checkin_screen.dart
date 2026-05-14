import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../presentation/themes/app_theme.dart';
import '../../../presentation/controllers/absensi_controller.dart';
import '../../../presentation/widgets/common_widgets.dart';
import '../../../data/models/session_model.dart';

class CheckinScreen extends StatelessWidget {
  const CheckinScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AbsensiController>();
    final SessionModel sesi = Get.arguments as SessionModel;

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(title: const Text('Check-in Absensi')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info sesi
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.event_note_rounded, color: AppColors.primary, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(sesi.title, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary, fontSize: 14)),
                        Text(sesi.kelasName ?? '-', style: const TextStyle(color: AppColors.primary, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Selfie Camera (Platform-specific feature) ──────────
            const Text('Foto Selfie', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.ink)),
            const SizedBox(height: 4),
            const Text('Ambil foto selfie sebagai bukti kehadiran', style: TextStyle(color: AppColors.inkMuted, fontSize: 12)),
            const SizedBox(height: 10),
            Obx(() => GestureDetector(
                  onTap: ctrl.takeSelfie,
                  child: Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: ctrl.selfieImagePath.value != null ? AppColors.primary : AppColors.ink.withOpacity(0.1),
                        width: ctrl.selfieImagePath.value != null ? 2 : 1,
                      ),
                    ),
                    child: ctrl.selfieImagePath.value != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.file(File(ctrl.selfieImagePath.value!), fit: BoxFit.cover),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.primarySoft,
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: const Icon(Icons.camera_alt_rounded, color: AppColors.primary, size: 32),
                              ),
                              const SizedBox(height: 10),
                              const Text('Tap untuk ambil foto selfie', style: TextStyle(color: AppColors.inkMuted, fontSize: 13)),
                            ],
                          ),
                  ),
                )),
            const SizedBox(height: 24),

            // ── GPS Location (Platform-specific feature) ───────────
            if (sesi.hasLocation) ...[
              const Text('Lokasi GPS', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.ink)),
              const SizedBox(height: 4),
              Text('Sesi ini memerlukan validasi lokasi (radius ${sesi.radiusMeters.round()}m)', style: const TextStyle(color: AppColors.inkMuted, fontSize: 12)),
              const SizedBox(height: 10),
              Obx(() => GestureDetector(
                    onTap: ctrl.isLocating.value ? null : ctrl.getLocation,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: ctrl.currentLatitude.value != null ? AppColors.success : AppColors.ink.withOpacity(0.1),
                          width: ctrl.currentLatitude.value != null ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: ctrl.currentLatitude.value != null ? AppColors.success.withOpacity(0.1) : AppColors.ink.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              ctrl.isLocating.value ? Icons.location_searching_rounded : Icons.my_location_rounded,
                              color: ctrl.currentLatitude.value != null ? AppColors.success : AppColors.inkMuted,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ctrl.isLocating.value
                                ? const Text('Mendapat lokasi...', style: TextStyle(color: AppColors.inkMuted))
                                : ctrl.currentLatitude.value != null
                                    ? Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text('Lokasi berhasil didapat ✓', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w600, fontSize: 13)),
                                          Text(
                                            '${ctrl.currentLatitude.value!.toStringAsFixed(5)}, ${ctrl.currentLongitude.value!.toStringAsFixed(5)}',
                                            style: const TextStyle(color: AppColors.inkMuted, fontSize: 11, fontFamily: 'monospace'),
                                          ),
                                        ],
                                      )
                                    : const Text('Tap untuk ambil lokasi GPS', style: TextStyle(color: AppColors.inkMuted, fontSize: 13)),
                          ),
                          if (ctrl.isLocating.value)
                            const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                        ],
                      ),
                    ),
                  )),
              const SizedBox(height: 24),
            ],

            // Submit button
            Obx(() => AppButton(
                  label: 'Submit Absensi',
                  icon: Icons.fingerprint_rounded,
                  isLoading: ctrl.isSubmitting.value,
                  onPressed: () => ctrl.submitCheckIn(sesi.id),
                )),
            const SizedBox(height: 12),
            AppButton(
              label: 'Batal',
              color: AppColors.ink.withOpacity(0.06),
              textColor: AppColors.inkMuted,
              onPressed: () => Get.back(),
            ),
          ],
        ),
      ),
    );
  }
}
