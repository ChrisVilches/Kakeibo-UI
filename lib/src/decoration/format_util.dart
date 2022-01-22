import 'package:intl/intl.dart';
import 'package:kakeibo_ui/src/enums/currency_symbol.dart';

class FormatUtil {
  static CurrencySymbol _currencySymbol = CurrencySymbol.dollar;

  static String formatNumberCommas(int? num) {
    if (num == null) return '';
    final formatter = NumberFormat.decimalPattern();
    return formatter.format(num);
  }

  static String formatNumberCurrency(int? num) {
    if (num == null) return '';
    String sign = num > 0 ? '' : '-';
    return "$sign${_currencySymbol.symbol}${formatNumberCommas(num.abs())}";
  }

  /// Configure the currency formatter globally.
  static void setCurrency(CurrencySymbol newSymbol) {
    _currencySymbol = newSymbol;
  }
}
