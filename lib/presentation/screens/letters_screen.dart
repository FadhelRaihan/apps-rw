import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/letter_model.dart';
import '../../data/models/user_model.dart';
import '../../state/app_state.dart';
import '../widgets/role_switcher_bar.dart';
import '../widgets/status_badge.dart';
import '../widgets/letter_detail_modal.dart';

class LettersScreen extends StatefulWidget {
  const LettersScreen({super.key});

  @override
  State<LettersScreen> createState() => _LettersScreenState();
}

class _LettersScreenState extends State<LettersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final user = state.currentUser;

    // Tabs adjust dynamically based on logged in role
    final isPengurus = user.role.isPengurus;
    final approvalTabTitle = user.role == UserRole.ketuaRt
        ? 'Perlu Verif RT (${state.pendingRtLetters.length})'
        : 'Perlu Sah RW (${state.pendingRwLetters.length})';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Layanan Administrasi Surat', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          indicatorColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: [
            const Tab(text: 'Pengajuan & Riwayat'),
            Tab(text: isPengurus ? approvalTabTitle : 'Katalog Surat'),
          ],
        ),
      ),
      body: Column(
        children: [
          const RoleSwitcherBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMyRequestsTab(context, state),
                isPengurus ? _buildApprovalTab(context, state, user) : _buildCatalogTab(context, state),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Ajukan Surat Baru', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: () => _showCreateLetterDialog(context, state),
      ),
    );
  }

  Widget _buildMyRequestsTab(BuildContext context, AppState state) {
    final list = state.residentLetters;

    if (list.isEmpty) {
      return const Center(
        child: Text('Belum ada riwayat permohonan surat.', style: TextStyle(color: AppColors.textSecondary)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final item = list[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => LetterDetailModal.show(context, item),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item.id,
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                        ),
                      ),
                      StatusBadge.fromLetterStatus(item.status),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    item.letterType.displayName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Keperluan: ${item.purpose}',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormatter.formatShort(item.requestDate),
                        style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                      ),
                      const Row(
                        children: [
                          Text('Lihat Pratinjau', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
                          Icon(Icons.arrow_forward_ios_rounded, size: 11, color: AppColors.primary),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildApprovalTab(BuildContext context, AppState state, UserProfile user) {
    final list = user.role == UserRole.ketuaRt ? state.pendingRtLetters : state.pendingRwLetters;

    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.done_all_rounded, size: 48, color: AppColors.accentGreen),
            const SizedBox(height: 10),
            Text(
              user.role == UserRole.ketuaRt
                  ? 'Semua permohonan warga RT 02 telah diverifikasi!'
                  : 'Semua permohonan tingkat RW telah disetujui!',
              style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final item = list[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pemohon: ${item.residentName} (RT ${item.rtNumber})',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary),
                    ),
                    StatusBadge.fromLetterStatus(item.status),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  item.letterType.displayName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  'Keperluan: ${item.purpose}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 10)),
                        onPressed: () => LetterDetailModal.show(context, item),
                        child: const Text('Detail', style: TextStyle(fontSize: 12)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          backgroundColor: user.role == UserRole.ketuaRt ? AppColors.roleRt : AppColors.roleRw,
                        ),
                        onPressed: () {
                          if (user.role == UserRole.ketuaRt) {
                            state.verifyLetterByRt(item.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Surat diverifikasi RT 02! Diteruskan ke RW.'), backgroundColor: AppColors.accentGreen),
                            );
                          } else {
                            state.approveLetterByRw(item.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Surat disahkan RW 05 dengan QR Code Digital!'), backgroundColor: AppColors.accentGreen),
                            );
                          }
                        },
                        child: Text(
                          user.role == UserRole.ketuaRt ? 'Verifikasi RT' : 'Sahkan RW',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCatalogTab(BuildContext context, AppState state) {
    const catalog = [
      LetterType.pengantarRtRw,
      LetterType.keteranganDomisili,
      LetterType.keteranganUsaha,
      LetterType.keteranganTidakMampu,
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: catalog.length,
      itemBuilder: (context, index) {
        final type = catalog[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.article_rounded, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(type.displayName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 4),
                      Text(type.defaultDescription, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_rounded, color: AppColors.primary),
                  onPressed: () => _showCreateLetterDialog(context, state, initialType: type),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCreateLetterDialog(BuildContext context, AppState state, {LetterType? initialType}) {
    LetterType selectedType = initialType ?? LetterType.pengantarRtRw;
    final purposeCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Buat Permohonan Surat', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Pilih Jenis Surat:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                DropdownButtonFormField<LetterType>(
                  initialValue: selectedType,
                  decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                  items: LetterType.values.map((t) {
                    return DropdownMenuItem(value: t, child: Text(t.displayName, style: const TextStyle(fontSize: 12)));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setDialogState(() => selectedType = val);
                  },
                ),
                const SizedBox(height: 14),
                const Text('Tujuan & Keperluan:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                TextField(
                  controller: purposeCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Contoh: Pengajuan KTP Baru / Syarat KUR Bank',
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline_rounded, size: 16, color: AppColors.primary),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Permohonan akan langsung masuk ke Ketua RT 02 untuk diverifikasi sebelum diteruskan ke RW 05.',
                          style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                final purpose = purposeCtrl.text.trim();
                if (purpose.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Harap isi keperluan pengajuan surat!')),
                  );
                  return;
                }
                state.submitLetterRequest(letterType: selectedType, purpose: purpose);
                Navigator.pop(dialogCtx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Permohonan surat berhasil dikirim! Menunggu verifikasi RT 02.'),
                    backgroundColor: AppColors.accentGreen,
                  ),
                );
              },
              child: const Text('Kirim Pengajuan'),
            ),
          ],
        ),
      ),
    );
  }
}
