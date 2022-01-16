import 'package:intl/intl.dart';

class FormatUtil {
  static String formatNumberCommas(int? num) {
    if (num == null) return '';
    final formatter = NumberFormat.decimalPattern();
    return formatter.format(num);
  }

  // TODO: Configure currency.
  static String formatNumberCurrency(int? num) {
    if (num == null) return '';
    return "¥${formatNumberCommas(num)}";
  }
}
