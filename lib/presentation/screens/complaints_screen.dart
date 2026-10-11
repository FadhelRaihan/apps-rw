import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/complaint_model.dart';
import '../../data/models/user_model.dart';
import '../../state/app_state.dart';
import '../widgets/role_switcher_bar.dart';
import '../widgets/status_badge.dart';

class ComplaintsScreen extends StatelessWidget {
  const ComplaintsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final complaints = state.allComplaints;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaduan & Aspirasi Warga', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
      body: Column(
        children: [
          const RoleSwitcherBar(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Info banner regarding anonymous mode
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryContainer.withAlpha(120),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.secondary.withAlpha(50)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.privacy_tip_outlined, color: AppColors.secondary, size: 24),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Fitur Perlindungan Warga: Anda dapat memilih opsi "Anonim" saat mengadu hal sensitif untuk menjaga kerukunan warga tanpa khawatir identitas tersebar.',
                          style: TextStyle(fontSize: 11, color: AppColors.onSecondaryContainer, height: 1.3),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Daftar Aduan & Tindak Lanjut', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text('${complaints.length} Laporan', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
                const SizedBox(height: 10),
                ...complaints.map((item) => _complaintCard(context, state, item)),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFD97706),
        icon: const Icon(Icons.rate_review_rounded, color: Colors.white),
        label: const Text('Tulis Pengaduan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: () => _showCreateComplaintDialog(context, state),
      ),
    );
  }

  Widget _complaintCard(BuildContext context, AppState state, ComplaintItem item) {
    final user = state.currentUser;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: item.isAnonymous ? Colors.grey.shade200 : AppColors.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        item.isAnonymous ? Icons.visibility_off_rounded : Icons.person_rounded,
                        size: 14,
                        color: item.isAnonymous ? Colors.grey.shade700 : AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      item.displayedReporter,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: item.isAnonymous ? Colors.grey.shade700 : AppColors.primary,
                      ),
                    ),
                  ],
                ),
                StatusBadge.fromComplaintStatus(item.status),
              ],
            ),
            const SizedBox(height: 10),
            Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 4),
            Text(item.description, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.3)),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    item.category.displayName,
                    style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  DateFormatter.formatDateTime(item.createdAt),
                  style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                ),
              ],
            ),
            // Admin follow-up note
            if (item.adminResponse != null) ...[
              const Divider(height: 16),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.accentGreenLight.withAlpha(120),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.reply_rounded, size: 16, color: Color(0xFF065F46)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Respon Pengurus Lingkungan:',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF065F46)),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.adminResponse!,
                            style: const TextStyle(fontSize: 11, color: Color(0xFF047857)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            // Action for pengurus to respond during demo
            if (user.role.isPengurus && item.status != ComplaintStatus.selesai) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  icon: const Icon(Icons.edit_note_rounded, size: 18),
                  label: const Text('Tanggapi Laporan Ini', style: TextStyle(fontSize: 12)),
                  onPressed: () => _showRespondDialog(context, state, item),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showCreateComplaintDialog(BuildContext context, AppState state) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    ComplaintCategory selectedCategory = ComplaintCategory.infrastruktur;
    bool isAnonymous = false;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Tulis Pengaduan Warga', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Judul Masalah / Keluhan:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(hintText: 'Misal: Lampu PJU Mati / Saluran Mampet'),
                ),
                const SizedBox(height: 12),
                const Text('Kategori:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                DropdownButtonFormField<ComplaintCategory>(
                  initialValue: selectedCategory,
                  decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                  items: ComplaintCategory.values.map((c) {
                    return DropdownMenuItem(value: c, child: Text(c.displayName, style: const TextStyle(fontSize: 12)));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setDialogState(() => selectedCategory = val);
                  },
                ),
                const SizedBox(height: 12),
                const Text('Penjelasan Rinci:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                TextField(
                  controller: descCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(hintText: 'Jelaskan lokasi tepat dan kronologi singkat...'),
                ),
                const SizedBox(height: 12),
                // Anonymous Toggle Switch
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isAnonymous ? Colors.amber.shade50 : AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isAnonymous ? Colors.amber.shade400 : AppColors.surfaceBorder),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isAnonymous ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                        color: isAnonymous ? Colors.amber.shade800 : AppColors.textSecondary,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Kirim Sebagai Anonim',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Identitas nama dirahasiakan',
                              style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: isAnonymous,
                        activeThumbColor: Colors.amber.shade800,
                        onChanged: (val) => setDialogState(() => isAnonymous = val),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () {
                final title = titleCtrl.text.trim();
                final desc = descCtrl.text.trim();
                if (title.isEmpty || desc.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Harap lengkapi judul dan rincian aduan!')),
                  );
                  return;
                }
                state.submitComplaint(
                  title: title,
                  description: desc,
                  category: selectedCategory,
                  isAnonymous: isAnonymous,
                );
                Navigator.pop(dialogCtx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isAnonymous
                          ? 'Pengaduan dikirim secara ANONIM. Privasi Anda terjaga.'
                          : 'Pengaduan berhasil dikirim ke pengurus.',
                    ),
                    backgroundColor: AppColors.accentGreen,
                  ),
                );
              },
              child: const Text('Kirim Aduan'),
            ),
          ],
        ),
      ),
    );
  }

  void _showRespondDialog(BuildContext context, AppState state, ComplaintItem item) {
    final noteCtrl = TextEditingController(text: item.adminResponse ?? '');
    ComplaintStatus status = ComplaintStatus.diproses;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Tindak Lanjut Pengaduan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Laporan: ${item.title}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Text('Ubah Status:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              DropdownButtonFormField<ComplaintStatus>(
                initialValue: status,
                decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                items: const [
                  DropdownMenuItem(value: ComplaintStatus.diproses, child: Text('Sedang Ditindaklanjuti', style: TextStyle(fontSize: 12))),
                  DropdownMenuItem(value: ComplaintStatus.selesai, child: Text('Selesai Ditangani', style: TextStyle(fontSize: 12))),
                ],
                onChanged: (val) {
                  if (val != null) setDialogState(() => status = val);
                },
              ),
              const SizedBox(height: 12),
              const Text('Catatan Respon Pengurus:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              TextField(
                controller: noteCtrl,
                maxLines: 3,
                decoration: const InputDecoration(hintText: 'Contoh: Sudah dikoordinasikan dengan petugas kebersihan...'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () {
                state.respondComplaint(
                  complaintId: item.id,
                  responseNote: noteCtrl.text.trim().isEmpty ? 'Telah ditinjau pengurus.' : noteCtrl.text.trim(),
                  newStatus: status,
                );
                Navigator.pop(dialogCtx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Status pengaduan berhasil diperbarui.'), backgroundColor: AppColors.accentGreen),
                );
              },
              child: const Text('Simpan Tindak Lanjut'),
            ),
          ],
        ),
      ),
    );
  }
}
