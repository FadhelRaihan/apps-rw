import 'package:intl/intl.dart';

/// Formatter helper for Indonesian Rupiah currency values.
class CurrencyFormatter {
  static final NumberFormat _rupiahFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  /// Format numeric integer/double to 'Rp 50.000'
  static String format(num amount) {
    return _rupiahFormat.format(amount);
  }

  /// Compact format for dashboard badges (e.g., 'Rp 5.2 Jt')
  static String formatCompact(num amount) {
    if (amount >= 1000000000) {
      return 'Rp ${(amount / 1000000000).toStringAsFixed(1)} M';
    } else if (amount >= 1000000) {
      return 'Rp ${(amount / 1000000).toStringAsFixed(1)} Jt';
    } else if (amount >= 1000) {
      return 'Rp ${(amount / 1000).toStringAsFixed(0)} Rb';
    }
    return format(amount);
  }
}
