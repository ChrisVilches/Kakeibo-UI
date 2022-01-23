enum CurrencySymbol { dollar, euro, yen }

extension CurrencySymbolExtension on CurrencySymbol {
  String get symbol {
    switch (this) {
      case CurrencySymbol.yen:
        return '¥';
      case CurrencySymbol.euro:
        return '€';
      default:
        return '\$';
    }
  }
}
