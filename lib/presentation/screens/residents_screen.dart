import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/resident_model.dart';
import '../../data/models/user_model.dart';
import '../../state/app_state.dart';
import '../widgets/role_switcher_bar.dart';

class ResidentsScreen extends StatelessWidget {
  const ResidentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final kk = state.familyCard;
    final user = state.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pencatatan Penduduk Mandiri', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
      body: Column(
        children: [
          const RoleSwitcherBar(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Info banner
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer.withAlpha(120),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.primaryLight.withAlpha(60)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.how_to_reg_rounded, color: AppColors.primary, size: 24),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Sensus Mandiri: Warga dapat mendaftarkan atau memperbarui data anggota keluarga di KK secara mandiri, yang selanjutnya diverifikasi oleh pengurus RW.',
                          style: TextStyle(fontSize: 11, color: AppColors.onPrimaryContainer, height: 1.3),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Family Card Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.surfaceBorder),
                    boxShadow: const [
                      BoxShadow(color: Color(0x06000000), blurRadius: 10, offset: Offset(0, 3)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.badge_rounded, color: AppColors.primary, size: 20),
                              SizedBox(width: 8),
                              Text('KARTU KELUARGA DIGITAL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.accentGreenLight,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('RT 02 / RW 05', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF065F46))),
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      _infoRow('Nomor KK', kk.noKk),
                      _infoRow('Kepala Keluarga', kk.headOfFamilyName),
                      _infoRow('Alamat Domisili', kk.address),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Daftar Anggota Keluarga (${kk.members.length})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    TextButton.icon(
                      icon: const Icon(Icons.person_add_rounded, size: 16),
                      label: const Text('Tambah Anggota', style: TextStyle(fontSize: 12)),
                      onPressed: () => _showAddMemberDialog(context, state),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...kk.members.map((member) => _memberCard(context, state, member, user.role.isPengurus)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(width: 110, child: Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary))),
          const Text(': ', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  Widget _memberCard(BuildContext context, AppState state, FamilyMember member, bool isPengurus) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.primaryContainer,
              child: Icon(
                member.gender == 'Laki-laki' ? Icons.male_rounded : Icons.female_rounded,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(member.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(member.relation, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text('NIK: ${member.nik}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  const SizedBox(height: 2),
                  Text('${member.birthDate} • ${member.occupation}', style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                ],
              ),
            ),
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: member.isVerified ? AppColors.accentGreenLight : AppColors.accentAmberLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        member.isVerified ? Icons.check_circle_rounded : Icons.schedule_rounded,
                        size: 11,
                        color: member.isVerified ? const Color(0xFF065F46) : const Color(0xFF92400E),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        member.isVerified ? 'Terverifikasi' : 'Pending RW',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: member.isVerified ? const Color(0xFF065F46) : const Color(0xFF92400E),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!member.isVerified && isPengurus) ...[
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: () {
                      state.verifyFamilyMember(member.nik);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Anggota keluarga berhasil diverifikasi oleh RW!'), backgroundColor: AppColors.accentGreen),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('Verifikasi', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddMemberDialog(BuildContext context, AppState state) {
    final nameCtrl = TextEditingController();
    final nikCtrl = TextEditingController();
    final occupationCtrl = TextEditingController();
    final birthDateCtrl = TextEditingController();
    String relation = 'Anak';
    String gender = 'Laki-laki';

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Tambah Anggota Keluarga', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nama Lengkap Sesuai Akta/KTP')),
                const SizedBox(height: 10),
                TextField(controller: nikCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Nomor Induk Kependudukan (NIK)')),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: relation,
                  decoration: const InputDecoration(labelText: 'Hubungan Keluarga'),
                  items: ['Istri', 'Anak', 'Orang Tua', 'Famili Lain'].map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                  onChanged: (val) {
                    if (val != null) setDialogState(() => relation = val);
                  },
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: gender,
                  decoration: const InputDecoration(labelText: 'Jenis Kelamin'),
                  items: ['Laki-laki', 'Perempuan'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                  onChanged: (val) {
                    if (val != null) setDialogState(() => gender = val);
                  },
                ),
                const SizedBox(height: 10),
                TextField(controller: birthDateCtrl, decoration: const InputDecoration(labelText: 'Tanggal Lahir (DD-MM-YYYY)')),
                const SizedBox(height: 10),
                TextField(controller: occupationCtrl, decoration: const InputDecoration(labelText: 'Pekerjaan')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () {
                final name = nameCtrl.text.trim();
                final nik = nikCtrl.text.trim();
                if (name.isEmpty || nik.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nama dan NIK wajib diisi!')));
                  return;
                }
                final newMember = FamilyMember(
                  nik: nik,
                  name: name,
                  relation: relation,
                  gender: gender,
                  birthDate: birthDateCtrl.text.trim().isEmpty ? '01-01-2010' : birthDateCtrl.text.trim(),
                  occupation: occupationCtrl.text.trim().isEmpty ? 'Pelajar' : occupationCtrl.text.trim(),
                  isVerified: false, // will require RW verification
                );
                state.addFamilyMember(newMember);
                Navigator.pop(dialogCtx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Anggota keluarga ditambahkan! Menunggu verifikasi pengurus RW.'),
                    backgroundColor: AppColors.accentGreen,
                  ),
                );
              },
              child: const Text('Simpan Data'),
            ),
          ],
        ),
      ),
    );
  }
}
