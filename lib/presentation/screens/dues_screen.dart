import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/finance_model.dart';
import '../../state/app_state.dart';
import '../widgets/role_switcher_bar.dart';
import '../widgets/payment_modal.dart';

class DuesScreen extends StatefulWidget {
  const DuesScreen({super.key});

  @override
  State<DuesScreen> createState() => _DuesScreenState();
}

class _DuesScreenState extends State<DuesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  WalletScope _selectedWalletScope = WalletScope.rt;

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kas & Pembayaran Iuran', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          indicatorColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(text: 'Tagihan Iuran Saya'),
            Tab(text: 'Buku Kas Transparan'),
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
                _buildMyBillsTab(context),
                _buildCashflowTab(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyBillsTab(BuildContext context) {
    final state = context.watch<AppState>();
    final bills = state.allBills;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.primaryContainer.withAlpha(120),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.primaryLight.withAlpha(50)),
          ),
          child: const Row(
            children: [
              Icon(Icons.shield_outlined, color: AppColors.primary, size: 22),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Multi-Dompet Otomatis: Iuran RT masuk ke rekening Bendahara RT, dan Iuran RW masuk langsung ke rekening Bendahara RW.',
                  style: TextStyle(fontSize: 11, color: AppColors.onPrimaryContainer, height: 1.3),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text('Daftar Tagihan Iuran Bulanan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 10),
        ...bills.map((bill) => _billCard(context, bill)),
      ],
    );
  }

  Widget _billCard(BuildContext context, DuesBill bill) {
    final isRt = bill.scope == WalletScope.rt;
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isRt ? AppColors.roleRt.withAlpha(25) : AppColors.roleRw.withAlpha(25),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    bill.scope.displayName,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isRt ? AppColors.roleRt : AppColors.roleRw,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: bill.isPaid ? AppColors.accentGreenLight : AppColors.emergencyRedLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    bill.isPaid ? 'LUNAS' : 'BELUM DIBAYAR',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: bill.isPaid ? const Color(0xFF065F46) : AppColors.emergencyRedDark,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(bill.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 4),
            Text(
              'Periode: ${bill.month} ${bill.year}',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Nominal Iuran', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                    Text(
                      CurrencyFormatter.format(bill.amount),
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.primary),
                    ),
                  ],
                ),
                if (!bill.isPaid)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    icon: const Icon(Icons.payment_rounded, size: 16),
                    label: const Text('Bayar Sekarang', style: TextStyle(fontSize: 12)),
                    onPressed: () => PaymentModal.show(context, bill),
                  )
                else
                  Row(
                    children: [
                      const Icon(Icons.verified_rounded, color: AppColors.accentGreen, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        'Via ${bill.paymentMethod ?? 'Online'}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.accentGreen),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCashflowTab(BuildContext context) {
    final state = context.watch<AppState>();
    final isRt = _selectedWalletScope == WalletScope.rt;
    final currentBalance = isRt ? state.rtBalance : state.rwBalance;
    final filteredTransactions = state.allTransactions.where((t) => t.scope == _selectedWalletScope).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Scope switcher pill
        Row(
          children: [
            Expanded(
              child: _scopePill(
                title: 'Dompet Kas RT 02',
                scope: WalletScope.rt,
                isSelected: isRt,
                color: AppColors.roleRt,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _scopePill(
                title: 'Dompet Kas RW 05',
                scope: WalletScope.rw,
                isSelected: !isRt,
                color: AppColors.roleRw,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Balance summary card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isRt
                  ? [const Color(0xFF1E3A8A), const Color(0xFF3B82F6)]
                  : [const Color(0xFF064E3B), const Color(0xFF059669)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: (isRt ? Colors.blue : Colors.teal).withAlpha(80),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Saldo Riil ${_selectedWalletScope.displayName}',
                    style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.lock_open_rounded, size: 12, color: Colors.white),
                        SizedBox(width: 4),
                        Text(
                          'Transparansi Terbuka',
                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                CurrencyFormatter.format(currentBalance),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 26,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _selectedWalletScope.description,
                style: const TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Riwayat Cashflow Masuk & Keluar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            Text(
              '${filteredTransactions.length} Transaksi',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (filteredTransactions.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text('Belum ada transaksi di dompet ini.', style: TextStyle(color: AppColors.textSecondary)),
            ),
          )
        else
          ...filteredTransactions.map((tx) => _transactionTile(tx)),
      ],
    );
  }

  Widget _scopePill({
    required String title,
    required WalletScope scope,
    required bool isSelected,
    required Color color,
  }) {
    return InkWell(
      onTap: () => setState(() => _selectedWalletScope = scope),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? color : AppColors.surfaceBorder, width: 1.5),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _transactionTile(CashflowTransaction tx) {
    final isIncome = tx.type == TransactionType.income;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isIncome ? AppColors.accentGreenLight : AppColors.emergencyRedLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
              color: isIncome ? const Color(0xFF065F46) : AppColors.emergencyRedDark,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  '${tx.category} • ${DateFormatter.formatShort(tx.date)}',
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
                if (tx.note != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    tx.note!,
                    style: const TextStyle(fontSize: 10, color: AppColors.textMuted, fontStyle: FontStyle.italic),
                  ),
                ],
              ],
            ),
          ),
          Text(
            '${isIncome ? '+' : '-'}${CurrencyFormatter.format(tx.amount)}',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 13,
              color: isIncome ? AppColors.accentGreen : AppColors.emergencyRed,
            ),
          ),
        ],
      ),
    );
  }
}
