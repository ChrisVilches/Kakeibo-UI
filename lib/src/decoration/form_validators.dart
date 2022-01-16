class FormValidators {
  static String? amountValidator(value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the amount';
    }

    try {
      int num = int.parse(value);
      if (num < 0) return 'Enter a positive number';
    } catch (_) {
      return 'Enter a number';
    }

    return null;
  }
}
