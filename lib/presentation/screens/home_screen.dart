import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/user_model.dart';
import '../../data/models/news_model.dart';
import '../../data/models/emergency_model.dart';
import '../../state/app_state.dart';
import '../widgets/role_switcher_bar.dart';
import '../widgets/emergency_modal.dart';
import '../widgets/payment_modal.dart';
import 'news_screen.dart';

class HomeScreen extends StatelessWidget {
  final Function(int) onNavigateTab;

  const HomeScreen({super.key, required this.onNavigateTab});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final user = state.currentUser;
    final isEmergency = state.isEmergencyActive;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.maps_home_work_rounded, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Desa Apps - RW 05',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                Text(
                  'Sistem Layanan Komunitas Digital',
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tidak ada notifikasi penting yang terlewat.')),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => await Future.delayed(const Duration(milliseconds: 400)),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Role Switcher for seamless pitching demo
              const RoleSwitcherBar(),

              // Active Siren Banner (High Priority Alarm)
              if (isEmergency)
                _buildActiveSirenBanner(context, state)
              else
                _buildEmergencyQuickButton(context),

              // Transparent Financial Overview (Kas RT & RW)
              _buildTransparentWallets(context, state),

              // Unpaid Bill Alert (If any)
              if (state.pendingBills.isNotEmpty && user.role == UserRole.warga)
                _buildPendingBillBanner(context, state),

              // 6 Core Features Grid
              _buildFeaturesGrid(context),

              // Recent Announcements / Agenda Section
              _buildRecentNewsSection(context, state),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveSirenBanner(BuildContext context, AppState state) {
    final alert = state.activeEmergency;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.emergencyRed,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.emergencyRed.withAlpha(120),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => EmergencyModal.show(context),
        child: Row(
          children: [
            const Icon(Icons.campaign_rounded, color: Colors.white, size: 36),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PERINGATAN: SIRINE BERBUNYI!',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14),
                  ),
                  Text(
                    '${alert?.reason ?? 'Darurat'} di ${alert?.scope.displayName} • ${alert?.affectedHousesCount} Sirine Aktif',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
              child: const Text(
                'Lihat / Matikan',
                style: TextStyle(color: AppColors.emergencyRed, fontWeight: FontWeight.bold, fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyQuickButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.emergencyRedLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.emergencyRed.withAlpha(80), width: 1.2),
      ),
      child: InkWell(
        onTap: () => EmergencyModal.show(context),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppColors.emergencyRed,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.campaign_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pusat Sirine Darurat (Panic Button)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.emergencyRedDark),
                  ),
                  Text(
                    'Koneksi langsung ke sirine fisik di seluruh rumah RT & RW',
                    style: TextStyle(fontSize: 11, color: Color(0xFF7F1D1D)),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.emergencyRed),
          ],
        ),
      ),
    );
  }

  Widget _buildTransparentWallets(BuildContext context, AppState state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.surfaceBorder),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 10, offset: Offset(0, 4)),
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
                  Icon(Icons.account_balance_wallet_rounded, size: 18, color: AppColors.primary),
                  SizedBox(width: 6),
                  Text(
                    'Transparansi Kas Lingkungan',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              InkWell(
                onTap: () => onNavigateTab(2), // Tab Kas
                child: const Text(
                  'Lihat Buku Kas >',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _walletCard(
                  title: 'Kas RT 02',
                  subtitle: 'Bendahara RT',
                  amount: state.rtBalance,
                  color: AppColors.roleRt,
                  icon: Icons.shield_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _walletCard(
                  title: 'Kas RW 05',
                  subtitle: 'Bendahara RW',
                  amount: state.rwBalance,
                  color: AppColors.roleRw,
                  icon: Icons.public_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _walletCard({
    required String title,
    required String subtitle,
    required double amount,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: color)),
              Icon(icon, size: 16, color: color),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            CurrencyFormatter.format(amount),
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 2),
          Text(subtitle, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildPendingBillBanner(BuildContext context, AppState state) {
    final firstBill = state.pendingBills.first;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.accentAmberLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.accentAmber.withAlpha(90)),
      ),
      child: Row(
        children: [
          const Icon(Icons.receipt_long_rounded, color: Color(0xFFB45309)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tagihan Iuran: ${firstBill.title}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF78350F)),
                ),
                Text(
                  'Jumlah: ${CurrencyFormatter.format(firstBill.amount)} (${firstBill.month} ${firstBill.year})',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF92400E)),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD97706),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: Size.zero,
            ),
            onPressed: () => PaymentModal.show(context, firstBill),
            child: const Text('Bayar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesGrid(BuildContext context) {
    final features = [
      {
        'title': 'Layanan Surat',
        'subtitle': 'Permohonan 1-Pintu',
        'icon': Icons.description_rounded,
        'color': const Color(0xFF0D9488),
        'tab': 1,
      },
      {
        'title': 'Kas & Iuran',
        'subtitle': 'Transparan RT & RW',
        'icon': Icons.payments_rounded,
        'color': const Color(0xFF2563EB),
        'tab': 2,
      },
      {
        'title': 'Pengaduan Warga',
        'subtitle': 'Aspirasi & Anonim',
        'icon': Icons.record_voice_over_rounded,
        'color': const Color(0xFFD97706),
        'tab': 3,
      },
      {
        'title': 'Pencatatan KK',
        'subtitle': 'Sensus Warga Mandiri',
        'icon': Icons.badge_rounded,
        'color': const Color(0xFF7C3AED),
        'tab': 4,
      },
      {
        'title': 'Berita & Info',
        'subtitle': 'Pengumuman & Agenda',
        'icon': Icons.newspaper_rounded,
        'color': const Color(0xFF0284C7),
        'action': () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NewsScreen()),
            ),
      },
      {
        'title': 'Sirine Darurat',
        'subtitle': 'Alarm Fisik IoT',
        'icon': Icons.campaign_rounded,
        'color': AppColors.emergencyRed,
        'action': () => EmergencyModal.show(context),
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Layanan Utama Warga RW 05',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: features.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.95,
            ),
            itemBuilder: (context, index) {
              final item = features[index];
              final color = item['color'] as Color;
              return InkWell(
                onTap: () {
                  if (item['action'] != null) {
                    (item['action'] as VoidCallback)();
                  } else if (item['tab'] != null) {
                    onNavigateTab(item['tab'] as int);
                  }
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.surfaceBorder),
                    boxShadow: const [
                      BoxShadow(color: Color(0x05000000), blurRadius: 4, offset: Offset(0, 2)),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: color.withAlpha(25),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(item['icon'] as IconData, color: color, size: 22),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item['title'] as String,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                        maxLines: 1,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item['subtitle'] as String,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 9, color: AppColors.textSecondary),
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRecentNewsSection(BuildContext context, AppState state) {
    final published = state.publishedNews.take(3).toList();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Informasi & Kegiatan Terkini',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              InkWell(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NewsScreen()),
                ),
                child: const Text(
                  'Lihat Semua >',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...published.map((news) => _newsCard(context, news)),
        ],
      ),
    );
  }

  Widget _newsCard(BuildContext context, NewsItem news) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              news.category == NewsCategory.pengumuman
                  ? Icons.campaign_rounded
                  : news.category == NewsCategory.agenda
                      ? Icons.event_rounded
                      : Icons.photo_camera_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        news.category.displayName,
                        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      DateFormatter.formatShort(news.createdAt),
                      style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  news.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  news.content,
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
