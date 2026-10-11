import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/user_model.dart';
import '../../state/app_state.dart';

/// Interactive role switcher pill and bottom sheet for live pitching demo.
class RoleSwitcherBar extends StatelessWidget {
  const RoleSwitcherBar({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final user = state.currentUser;

    Color badgeColor;
    switch (user.role) {
      case UserRole.warga:
        badgeColor = AppColors.roleWarga;
        break;
      case UserRole.ketuaRt:
      case UserRole.bendaharaRt:
        badgeColor = AppColors.roleRt;
        break;
      case UserRole.ketuaRw:
      case UserRole.bendaharaRw:
        badgeColor = AppColors.roleRw;
        break;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: badgeColor.withAlpha(80), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: badgeColor.withAlpha(20),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showRoleSelectorSheet(context),
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: badgeColor.withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.swap_horiz_rounded, size: 18, color: badgeColor),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Text(
                        'MODE DEMO PITCHING',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: badgeColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          user.role.displayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${user.name} • RT ${user.rtNumber} / RW ${user.rwNumber}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Text(
                    'Ganti Peran',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary),
                  ),
                  SizedBox(width: 2),
                  Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: AppColors.primary),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRoleSelectorSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final state = context.watch<AppState>();
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.switch_account_rounded, color: AppColors.primary),
                    const SizedBox(width: 10),
                    const Text(
                      'Pilih Simulasi Peran (Role)',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Ganti peran secara instan untuk memperagakan alur persetujuan surat, berita, dan transparansi kas.',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                _roleTile(
                  context: context,
                  title: 'Warga Biasa (RT 02)',
                  subtitle: 'Bambang Sutrisno • Pengajuan surat, lapor, bayar iuran',
                  role: UserRole.warga,
                  currentRole: state.currentUser.role,
                  color: AppColors.roleWarga,
                  icon: Icons.person_rounded,
                ),
                _roleTile(
                  context: context,
                  title: 'Ketua RT 02',
                  subtitle: 'H. Suherman S.Pd • Verifikasi pengantar surat RT, pantau kas RT',
                  role: UserRole.ketuaRt,
                  currentRole: state.currentUser.role,
                  color: AppColors.roleRt,
                  icon: Icons.admin_panel_settings_rounded,
                ),
                _roleTile(
                  context: context,
                  title: 'Ketua RW 05',
                  subtitle: 'Ir. Hendra Gunawan • Persetujuan akhir surat RW, moderasi berita',
                  role: UserRole.ketuaRw,
                  currentRole: state.currentUser.role,
                  color: AppColors.roleRw,
                  icon: Icons.verified_user_rounded,
                ),
                _roleTile(
                  context: context,
                  title: 'Bendahara RW 05',
                  subtitle: 'Dra. Hj. Nurjanah • Pengelolaan kas RW 05 dan laporan iuran',
                  role: UserRole.bendaharaRw,
                  currentRole: state.currentUser.role,
                  color: Colors.teal.shade800,
                  icon: Icons.account_balance_wallet_rounded,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _roleTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required UserRole role,
    required UserRole currentRole,
    required Color color,
    required IconData icon,
  }) {
    final isSelected = role == currentRole;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isSelected ? color.withAlpha(25) : AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected ? color : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withAlpha(40),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? color : AppColors.textPrimary,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        trailing: isSelected
            ? Icon(Icons.check_circle_rounded, color: color)
            : const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
        onTap: () {
          context.read<AppState>().switchRole(role);
          Navigator.pop(context);
        },
      ),
    );
  }
}
