import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/letter_model.dart';
import '../../data/models/user_model.dart';
import '../../state/app_state.dart';
import 'status_badge.dart';

/// Modal displaying letter request details, digital letter preview, and RT/RW approval controls.
class LetterDetailModal extends StatelessWidget {
  final LetterRequest letter;

  const LetterDetailModal({super.key, required this.letter});

  static void show(BuildContext context, LetterRequest letter) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => LetterDetailModal(letter: letter),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final currentUser = state.currentUser;
    // Keep updated status from state in case approved inside modal
    final currentLetter = state.allLetters.firstWhere(
      (l) => l.id == letter.id,
      orElse: () => letter,
    );

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        top: 20,
        left: 20,
        right: 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentLetter.letterType.displayName,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'ID: ${currentLetter.id}',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                StatusBadge.fromLetterStatus(currentLetter.status),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Progress tracker
            _buildTimelineTracker(currentLetter),
            const SizedBox(height: 16),
            // Digital Letter Document Preview Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        const Text(
                          'RUKUN WARGA 05 / RUKUN TETANGGA 02',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 0.5),
                        ),
                        Text(
                          'SURAT PELAYANAN ADMINISTRASI SATU PINTU',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade700, fontWeight: FontWeight.w600),
                        ),
                        const Divider(thickness: 1.2, height: 16),
                      ],
                    ),
                  ),
                  _dataRow('Nama Pemohon', currentLetter.residentName),
                  _dataRow('NIK Pemohon', currentLetter.nik),
                  _dataRow('Domisili Wilayah', 'RT ${currentLetter.rtNumber} / RW ${currentLetter.rwNumber}'),
                  _dataRow('Keperluan Pengajuan', currentLetter.purpose),
                  _dataRow('Tanggal Diajukan', DateFormatter.formatDateTime(currentLetter.requestDate)),
                  if (currentLetter.status == LetterStatus.disetujuiRw) ...[
                    const Divider(height: 16),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.accentGreen),
                          ),
                          child: const Icon(Icons.qr_code_rounded, color: AppColors.primary, size: 36),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Tanda Tangan Digital Sah',
                                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF065F46), fontSize: 12),
                              ),
                              Text(
                                'Kode: ${currentLetter.qrCodeVerification ?? 'VALID'}',
                                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Approval Actions based on active role
            if (currentUser.role == UserRole.ketuaRt && currentLetter.status == LetterStatus.diajukan) ...[
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  backgroundColor: AppColors.roleRt,
                ),
                icon: const Icon(Icons.check_circle_rounded),
                label: const Text('Verifikasi Pengantar RT (Kirim ke RW)'),
                onPressed: () {
                  state.verifyLetterByRt(currentLetter.id);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Surat telah diverifikasi RT 02 dan diteruskan ke Ketua RW 05.'),
                      backgroundColor: AppColors.accentGreen,
                    ),
                  );
                },
              ),
            ] else if (currentUser.role == UserRole.ketuaRw && currentLetter.status == LetterStatus.diverifikasiRt) ...[
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  backgroundColor: AppColors.roleRw,
                ),
                icon: const Icon(Icons.verified_rounded),
                label: const Text('Setujui & Terbitkan Surat Digital RW'),
                onPressed: () {
                  state.approveLetterByRw(currentLetter.id);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Surat berhasil disetujui RW 05 dan QR Code digital telah diterbitkan!'),
                      backgroundColor: AppColors.accentGreen,
                    ),
                  );
                },
              ),
            ] else if (currentLetter.status == LetterStatus.disetujuiRw) ...[
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                icon: const Icon(Icons.download_rounded),
                label: const Text('Unduh / Simpan Salinan Surat Digital'),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Surat digital berhasil diunduh ke memori perangkat.'),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineTracker(LetterRequest item) {
    final step = item.status.stepIndex;
    return Row(
      children: [
        _stepCircle(1, 'Pengajuan', step >= 1),
        _stepLine(step >= 2),
        _stepCircle(2, 'Verif RT', step >= 2),
        _stepLine(step >= 3),
        _stepCircle(3, 'Sah RW', step >= 3),
      ],
    );
  }

  Widget _stepCircle(int number, String label, bool isDone) {
    return Column(
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: isDone ? AppColors.accentGreen : AppColors.surfaceBorder,
          child: Text(
            number.toString(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isDone ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isDone ? FontWeight.bold : FontWeight.normal,
            color: isDone ? AppColors.textPrimary : AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _stepLine(bool isDone) {
    return Expanded(
      child: Container(
        height: 2,
        color: isDone ? AppColors.accentGreen : AppColors.surfaceBorder,
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
      ),
    );
  }

  Widget _dataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ),
          const Text(': ', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
