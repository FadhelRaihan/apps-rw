enum WalletScope {
  rt,
  rw,
}

extension WalletScopeExtension on WalletScope {
  String get displayName {
    switch (this) {
      case WalletScope.rt:
        return 'Kas RT 02';
      case WalletScope.rw:
        return 'Kas RW 05';
    }
  }

  String get description {
    switch (this) {
      case WalletScope.rt:
        return 'Dikelola oleh Bendahara RT untuk keamanan & operasional lokal RT';
      case WalletScope.rw:
        return 'Dikelola oleh Bendahara RW untuk kebersihan, posyandu & fasilitas umum RW';
    }
  }
}

enum TransactionType {
  income,
  expense,
}

class CashflowTransaction {
  final String id;
  final String title;
  final double amount;
  final TransactionType type;
  final WalletScope scope;
  final String rtNumber;
  final DateTime date;
  final String category;
  final String? note;

  const CashflowTransaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.scope,
    required this.rtNumber,
    required this.date,
    required this.category,
    this.note,
  });
}

class DuesBill {
  final String id;
  final String title;
  final double amount;
  final WalletScope scope;
  final String rtNumber;
  final String month;
  final int year;
  final bool isPaid;
  final DateTime? paidAt;
  final String? paymentMethod; // e.g. QRIS, BCA Virtual Account, GoPay

  const DuesBill({
    required this.id,
    required this.title,
    required this.amount,
    required this.scope,
    required this.rtNumber,
    required this.month,
    required this.year,
    required this.isPaid,
    this.paidAt,
    this.paymentMethod,
  });

  DuesBill copyWith({
    String? id,
    String? title,
    double? amount,
    WalletScope? scope,
    String? rtNumber,
    String? month,
    int? year,
    bool? isPaid,
    DateTime? paidAt,
    String? paymentMethod,
  }) {
    return DuesBill(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      scope: scope ?? this.scope,
      rtNumber: rtNumber ?? this.rtNumber,
      month: month ?? this.month,
      year: year ?? this.year,
      isPaid: isPaid ?? this.isPaid,
      paidAt: paidAt ?? this.paidAt,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }
}
