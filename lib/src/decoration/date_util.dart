import 'package:intl/intl.dart';

class DateUtil {
  static String formatDate(DateTime dt) {
    return DateFormat('yyyy-MM-dd').format(dt);
  }

  static String formatDateSlash(DateTime dt) {
    return DateFormat('yyyy/MM/dd').format(dt);
  }

  static String formatDateSlashNoYear(DateTime dt) {
    return DateFormat('MM/dd').format(dt);
  }

  static DateTime parseDate(String date) {
    DateFormat format = DateFormat('yyyy-MM-dd');
    return format.parse(date);
  }

  static List<String> formatDayRanges(DateTime from, DateTime to) {
    if (from.year == to.year) {
      return [formatDateSlash(from), formatDateSlashNoYear(to)];
    }

    return [formatDate(from), formatDate(to)];
  }
}
