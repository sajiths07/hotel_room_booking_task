/// Calendar-day helpers so booking logic never depends on time of day.
class DateHelper {
  const DateHelper._();

  static const List<String> _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  /// Strips hours, minutes, seconds, and milliseconds.
  static DateTime dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static int compareCalendarDays(DateTime a, DateTime b) {
    return dateOnly(a).compareTo(dateOnly(b));
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return compareCalendarDays(a, b) == 0;
  }

  static bool isBeforeDay(DateTime a, DateTime b) {
    return compareCalendarDays(a, b) < 0;
  }

  static bool isAfterDay(DateTime a, DateTime b) {
    return compareCalendarDays(a, b) > 0;
  }

  static bool isBeforeToday(DateTime date, DateTime today) {
    return isBeforeDay(date, today);
  }

  /// Checkout minus check-in in whole calendar days.
  ///
  /// Returns null when either date is missing or checkout is not after check-in.
  static int? nightsBetween(DateTime? checkIn, DateTime? checkOut) {
    if (checkIn == null || checkOut == null) {
      return null;
    }

    final nights = dateOnly(checkOut).difference(dateOnly(checkIn)).inDays;
    if (nights <= 0) {
      return null;
    }
    return nights;
  }

  static String formatDisplayDate(DateTime date) {
    final normalized = dateOnly(date);
    return '${normalized.day} ${_months[normalized.month - 1]} ${normalized.year}';
  }

  /// Half-open stay ranges: checkout day is free for the next guest.
  static bool staysOverlap({
    required DateTime startA,
    required DateTime endA,
    required DateTime startB,
    required DateTime endB,
  }) {
    return isBeforeDay(startA, endB) && isBeforeDay(startB, endA);
  }
}
