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

    String symbol = '\$';

    switch (_currencySymbol) {
      case CurrencySymbol.euro:
        symbol = '€';
        break;
      case CurrencySymbol.yen:
        symbol = '¥';
        break;
      default:
    }

    return "$symbol${formatNumberCommas(num)}";
  }

  /// Configure the currency formatter globally.
  static void setCurrency(CurrencySymbol newSymbol) {
    _currencySymbol = newSymbol;
  }
}
