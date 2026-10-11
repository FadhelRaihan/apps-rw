import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/models/finance_model.dart';
import '../../state/app_state.dart';

/// Interactive Payment Gateway simulator (QRIS / Virtual Account) for pitching.
class PaymentModal extends StatefulWidget {
  final DuesBill bill;

  const PaymentModal({super.key, required this.bill});

  static void show(BuildContext context, DuesBill bill) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PaymentModal(bill: bill),
    );
  }

  @override
  State<PaymentModal> createState() => _PaymentModalState();
}

class _PaymentModalState extends State<PaymentModal> {
  String _selectedMethod = 'QRIS';
  bool _isProcessing = false;

  final List<Map<String, dynamic>> _methods = [
    {
      'name': 'QRIS (Semua Bank & e-Wallet)',
      'code': 'QRIS',
      'icon': Icons.qr_code_2_rounded,
      'badge': 'Otomatis Realtime',
    },
    {
      'name': 'BCA Virtual Account',
      'code': 'BCA VA',
      'icon': Icons.account_balance_rounded,
      'badge': 'Cek Otomatis',
    },
    {
      'name': 'Bank Mandiri VA',
      'code': 'MANDIRI VA',
      'icon': Icons.account_balance_rounded,
      'badge': 'Cek Otomatis',
    },
    {
      'name': 'GoPay / ShopeePay',
      'code': 'GOPAY',
      'icon': Icons.account_balance_wallet_rounded,
      'badge': 'Instan',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final bill = widget.bill;

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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.payment_rounded, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Payment Gateway Terpadu', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('Simulasi pembayaran iuran otomatis 1-pintu', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(context)),
            ],
          ),
          const SizedBox(height: 14),
          // Bill summary card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.surfaceBorder),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        bill.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                    Text(
                      CurrencyFormatter.format(bill.amount),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: bill.scope == WalletScope.rt ? AppColors.roleRt.withAlpha(30) : AppColors.roleRw.withAlpha(30),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Tujuan: ${bill.scope.displayName}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: bill.scope == WalletScope.rt ? AppColors.roleRt : AppColors.roleRw,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Periode ${bill.month} ${bill.year}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text('Pilih Metode Pembayaran:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ..._methods.map((m) {
            final isSelected = _selectedMethod == m['code'];
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryContainer.withAlpha(120) : AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.surfaceBorder,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: ListTile(
                dense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                leading: Icon(m['icon'] as IconData, color: isSelected ? AppColors.primary : AppColors.textSecondary),
                title: Text(
                  m['name'] as String,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  ),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.accentGreenLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    m['badge'] as String,
                    style: const TextStyle(fontSize: 10, color: Color(0xFF065F46), fontWeight: FontWeight.bold),
                  ),
                ),
                onTap: () => setState(() => _selectedMethod = m['code'] as String),
              ),
            );
          }),
          const SizedBox(height: 14),
          // Interactive Action Button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: _isProcessing ? null : _executePayment,
            child: _isProcessing
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.verified_rounded, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Simulasikan Bayar via $_selectedMethod',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  void _executePayment() async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;

    final state = context.read<AppState>();
    state.payBillSimulated(
      billId: widget.bill.id,
      paymentMethod: _selectedMethod,
    );

    setState(() => _isProcessing = false);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.accentGreen,
        behavior: SnackBarBehavior.floating,
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Pembayaran ${widget.bill.title} LUNAS! Dana otomatis masuk ke ${widget.bill.scope.displayName}.',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
