import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/letter_model.dart';
import '../../data/models/complaint_model.dart';
import '../../data/models/news_model.dart';

class StatusBadge extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final IconData? icon;

  const StatusBadge({
    super.key,
    required this.text,
    required this.backgroundColor,
    required this.textColor,
    this.icon,
  });

  factory StatusBadge.fromLetterStatus(LetterStatus status) {
    switch (status) {
      case LetterStatus.diajukan:
        return StatusBadge(
          text: status.label,
          backgroundColor: AppColors.secondaryContainer,
          textColor: AppColors.onSecondaryContainer,
          icon: Icons.hourglass_top_rounded,
        );
      case LetterStatus.diverifikasiRt:
        return StatusBadge(
          text: status.label,
          backgroundColor: AppColors.accentAmberLight,
          textColor: const Color(0xFF92400E),
          icon: Icons.assignment_turned_in_rounded,
        );
      case LetterStatus.disetujuiRw:
        return StatusBadge(
          text: status.label,
          backgroundColor: AppColors.accentGreenLight,
          textColor: const Color(0xFF065F46),
          icon: Icons.verified_rounded,
        );
      case LetterStatus.ditolak:
        return StatusBadge(
          text: status.label,
          backgroundColor: AppColors.emergencyRedLight,
          textColor: AppColors.emergencyRedDark,
          icon: Icons.cancel_rounded,
        );
    }
  }

  factory StatusBadge.fromComplaintStatus(ComplaintStatus status) {
    switch (status) {
      case ComplaintStatus.menunggu:
        return StatusBadge(
          text: status.label,
          backgroundColor: AppColors.secondaryContainer,
          textColor: AppColors.onSecondaryContainer,
          icon: Icons.pending_actions_rounded,
        );
      case ComplaintStatus.diproses:
        return StatusBadge(
          text: status.label,
          backgroundColor: AppColors.accentAmberLight,
          textColor: const Color(0xFF92400E),
          icon: Icons.sync_rounded,
        );
      case ComplaintStatus.selesai:
        return StatusBadge(
          text: status.label,
          backgroundColor: AppColors.accentGreenLight,
          textColor: const Color(0xFF065F46),
          icon: Icons.check_circle_rounded,
        );
    }
  }

  factory StatusBadge.fromNewsStatus(NewsStatus status) {
    switch (status) {
      case NewsStatus.published:
        return const StatusBadge(
          text: 'Tayang',
          backgroundColor: AppColors.accentGreenLight,
          textColor: Color(0xFF065F46),
          icon: Icons.visibility_rounded,
        );
      case NewsStatus.pending:
        return const StatusBadge(
          text: 'Menunggu Persetujuan',
          backgroundColor: AppColors.accentAmberLight,
          textColor: Color(0xFF92400E),
          icon: Icons.schedule_rounded,
        );
      case NewsStatus.rejected:
        return const StatusBadge(
          text: 'Ditolak',
          backgroundColor: AppColors.emergencyRedLight,
          textColor: AppColors.emergencyRedDark,
          icon: Icons.block_rounded,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
