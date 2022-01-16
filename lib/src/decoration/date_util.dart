import 'package:intl/intl.dart';

class DateUtil {
  static String formatDate(DateTime dt) {
    return DateFormat('yyyy-MM-dd').format(dt);
  }

  static DateTime parseDate(String date) {
    DateFormat format = DateFormat("yyyy-MM-dd");
    return format.parse(date);
  }
}
