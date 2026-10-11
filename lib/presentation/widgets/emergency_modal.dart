import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/emergency_model.dart';
import '../../state/app_state.dart';

/// Modal to trigger or monitor emergency sirens across RT or RW hardware.
class EmergencyModal extends StatefulWidget {
  const EmergencyModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const EmergencyModal(),
    );
  }

  @override
  State<EmergencyModal> createState() => _EmergencyModalState();
}

class _EmergencyModalState extends State<EmergencyModal> with SingleTickerProviderStateMixin {
  EmergencyScope _selectedScope = EmergencyScope.rt;
  String _selectedReason = 'Kebakaran';
  final TextEditingController _customReasonCtrl = TextEditingController();
  double _holdProgress = 0.0;
  bool _isHolding = false;
  late AnimationController _pulseController;

  final List<String> _quickReasons = [
    'Kebakaran',
    'Maling / Pembobolan',
    'Banjir / Bencana',
    'Medis Darurat',
    'Keributan Warga',
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _customReasonCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isEmergencyActive = state.isEmergencyActive;
    final activeAlert = state.activeEmergency;

    return Container(
      decoration: BoxDecoration(
        color: isEmergencyActive ? AppColors.emergencyRedDark : AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 20,
        left: 20,
        right: 20,
      ),
      child: isEmergencyActive && activeAlert != null
          ? _buildActiveAlertView(context, state, activeAlert)
          : _buildTriggerAlertView(context, state),
    );
  }

  Widget _buildActiveAlertView(BuildContext context, AppState state, EmergencyAlert alert) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Transform.scale(
              scale: 1.0 + (_pulseController.value * 0.12),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.emergencyRed,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.emergencyRed.withAlpha((180 * _pulseController.value).toInt()),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(Icons.campaign_rounded, size: 48, color: Colors.white),
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        const Text(
          'SIRINE DARURAT SEDANG AKTIF!',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(30),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Sinyal IoT: ${alert.affectedHousesCount} Sirine Rumah Berbunyi (${alert.scope.displayName})',
            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withAlpha(50),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _infoRow('Pemicu Alarm', '${alert.initiatorName} (${alert.initiatorRt})'),
              const Divider(color: Colors.white24, height: 16),
              _infoRow('Kategori Bahaya', alert.reason),
              const Divider(color: Colors.white24, height: 16),
              _infoRow('Perangkat Hardware', 'ESP32 IoT Network Terhubung 100%'),
            ],
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.emergencyRed,
            minimumSize: const Size.fromHeight(50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          icon: const Icon(Icons.stop_circle_rounded, size: 24),
          label: const Text('NONAKTIFKAN / MATIKAN SIRINE', style: TextStyle(fontWeight: FontWeight.bold)),
          onPressed: () {
            state.resolveEmergency();
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Sirine darurat telah dinonaktifkan oleh pengurus.'),
                backgroundColor: AppColors.accentGreen,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }

  Widget _buildTriggerAlertView(BuildContext context, AppState state) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.emergencyRedLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.warning_amber_rounded, color: AppColors.emergencyRed, size: 24),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pusat Sirine Darurat Lingkungan',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Tersambung langsung ke modul sirine fisik di rumah warga',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          '1. Pilih Skala Wilayah Bahaya:',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _scopeOption(
                scope: EmergencyScope.rt,
                title: 'Skala RT (RT 02)',
                desc: '38 rumah warga',
                isSelected: _selectedScope == EmergencyScope.rt,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _scopeOption(
                scope: EmergencyScope.rw,
                title: 'Skala RW (RW 05)',
                desc: 'Seluruh 240 rumah',
                isSelected: _selectedScope == EmergencyScope.rw,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          '2. Jenis Kondisi Kedaruratan:',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _quickReasons.map((reason) {
            final isSelected = _selectedReason == reason;
            return ChoiceChip(
              label: Text(reason),
              selected: isSelected,
              selectedColor: AppColors.emergencyRedLight,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.emergencyRedDark : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
              onSelected: (selected) {
                if (selected) setState(() => _selectedReason = reason);
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        // Hold to confirm trigger
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.surfaceBorder),
          ),
          child: Column(
            children: [
              const Row(
                children: [
                  Icon(Icons.touch_app_rounded, size: 18, color: AppColors.emergencyRed),
                  SizedBox(width: 6),
                  Text(
                    'Pencegah Salah Pencet: Tahan 2 Detik',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTapDown: (_) {
                  setState(() => _isHolding = true);
                  _startHoldTimer(context, state);
                },
                onTapUp: (_) => setState(() {
                  _isHolding = false;
                  _holdProgress = 0.0;
                }),
                onTapCancel: () => setState(() {
                  _isHolding = false;
                  _holdProgress = 0.0;
                }),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: LinearProgressIndicator(
                        value: _holdProgress,
                        minHeight: 52,
                        backgroundColor: AppColors.emergencyRed,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.emergencyRedDark),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.campaign_rounded, color: Colors.white, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          _isHolding ? 'MENAHAN UNTUK MEMICU...' : 'TEKAN & TAHAN SIRINE DARURAT',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _startHoldTimer(BuildContext context, AppState state) async {
    const totalSteps = 20;
    for (int i = 1; i <= totalSteps; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (!_isHolding || !mounted) return;
      setState(() => _holdProgress = i / totalSteps);
    }
    if (_isHolding && mounted) {
      state.triggerEmergency(
        scope: _selectedScope,
        reason: _selectedReason,
      );
      setState(() {
        _isHolding = false;
        _holdProgress = 0.0;
      });
    }
  }

  Widget _scopeOption({
    required EmergencyScope scope,
    required String title,
    required String desc,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () => setState(() => _selectedScope = scope),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.emergencyRedLight : AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.emergencyRed : AppColors.surfaceBorder,
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                  size: 16,
                  color: isSelected ? AppColors.emergencyRed : AppColors.textMuted,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: isSelected ? AppColors.emergencyRedDark : AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(desc, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
