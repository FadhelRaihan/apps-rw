import 'package:intl/intl.dart';

/// Utility class for formatting dates and times in Indonesian format.
class DateFormatter {
  static final DateFormat _fullDate = DateFormat('d MMMM yyyy', 'id_ID');
  static final DateFormat _shortDate = DateFormat('d MMM yyyy', 'id_ID');
  static final DateFormat _dateTime = DateFormat('d MMM yyyy, HH:mm', 'id_ID');
  static final DateFormat _timeOnly = DateFormat('HH:mm', 'id_ID');

  static String formatFull(DateTime date) {
    try {
      return _fullDate.format(date);
    } catch (_) {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  static String formatShort(DateTime date) {
    try {
      return _shortDate.format(date);
    } catch (_) {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  static String formatDateTime(DateTime date) {
    try {
      return '${_dateTime.format(date)} WIB';
    } catch (_) {
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute} WIB';
    }
  }

  static String formatTime(DateTime date) {
    try {
      return '${_timeOnly.format(date)} WIB';
    } catch (_) {
      return '${date.hour}:${date.minute}';
    }
  }
}
