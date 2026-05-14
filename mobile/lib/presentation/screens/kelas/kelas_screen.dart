import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../presentation/themes/app_theme.dart';
import '../../../presentation/controllers/kelas_controller.dart';
import '../../../presentation/widgets/common_widgets.dart';
import '../../../data/models/kelas_model.dart';

class KelasScreen extends StatelessWidget {
  const KelasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<KelasController>();

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        title: const Text('Manajemen Kelas'),
        actions: [
          IconButton(
            onPressed: () => _showTambahAnggotaDialog(ctrl),
            icon: const Icon(Icons.person_add_rounded, color: AppColors.primary),
          ),
        ],
      ),
      body: Obx(() {
        if (ctrl.isLoading.value) return const Center(child: CircularProgressIndicator());
        if (ctrl.kelasList.isEmpty) return const EmptyState(icon: Icons.school_rounded, message: 'Belum ada kelas');

        return RefreshIndicator(
          onRefresh: ctrl.fetchKelas,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: ctrl.kelasList.length,
            itemBuilder: (_, i) => _KelasCard(kelas: ctrl.kelasList[i], ctrl: ctrl),
          ),
        );
      }),
    );
  }

  void _showTambahAnggotaDialog(KelasController ctrl) {
    final userIdCtrl = TextEditingController();
    String? selectedKelasId;
    String selectedRole = 'member';

    Get.dialog(
      StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Tambah Anggota', style: TextStyle(fontWeight: FontWeight.w700)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                controller: userIdCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'User ID',
                  hintText: 'ID user yang akan ditambahkan',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: selectedRole,
                decoration: InputDecoration(
                  labelText: 'Role',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: const [
                  DropdownMenuItem(value: 'member', child: Text('Member')),
                  DropdownMenuItem(value: 'leader', child: Text('Leader')),
                ],
                onChanged: (val) => setState(() => selectedRole = val!),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () {
                if (selectedKelasId == null || userIdCtrl.text.isEmpty) {
                  Get.snackbar('Error', 'Semua field wajib diisi', snackPosition: SnackPosition.BOTTOM);
                  return;
                }
                Get.back();
                ctrl.tambahAnggota(
                  kelasId: int.parse(selectedKelasId!),
                  userId: int.parse(userIdCtrl.text),
                  role: selectedRole,
                );
              },
              child: const Text('Tambah'),
            ),
          ],
        );
      }),
    );
  }
}

class _KelasCard extends StatelessWidget {
  final KelasModel kelas;
  final KelasController ctrl;

  const _KelasCard({required this.kelas, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.ink.withOpacity(0.06)),
      ),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          title: Text(kelas.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.ink)),
          subtitle: Text(kelas.orgName ?? '-', style: const TextStyle(color: AppColors.inkMuted, fontSize: 12)),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.school_rounded, color: AppColors.primary, size: 20),
          ),
          onExpansionChanged: (expanded) {
            if (expanded) ctrl.fetchAnggota(kelas.id);
          },
          children: [
            const Divider(height: 1),
            Obx(() {
              final anggota = ctrl.anggotaMap[kelas.id];
              if (anggota == null) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (anggota.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Belum ada anggota', style: TextStyle(color: AppColors.inkMuted)),
                );
              }
              return Column(
                children: anggota.map<Widget>((m) => ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primarySoft,
                        radius: 18,
                        child: Text(
                          (m['name'] as String).isNotEmpty ? (m['name'] as String)[0].toUpperCase() : '?',
                          style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                      ),
                      title: Text(m['name'] ?? '-', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      subtitle: Text(m['email'] ?? '-', style: const TextStyle(fontSize: 12, color: AppColors.inkMuted)),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primarySoft,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(m['role'] ?? '-', style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w600)),
                      ),
                    )).toList(),
              );
            }),
          ],
        ),
      ),
    );
  }
}
