typedef InputValidatorFn = String? Function(String?);

class FormValidators {
  static String? amountValidator(String? value) {
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

  static String? requiredField(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }

    return null;
  }

  static String? mustBeEmail(String? value) {
    final regex = RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    final bool emailValid = regex.hasMatch(value ?? '');

    if (emailValid) return null;

    return 'Must be an e-mail';
  }

  static InputValidatorFn pipe(List<InputValidatorFn> validators) {
    return (String? text) {
      for (var fn in validators) {
        String? validationResult = fn(text);
        if (validationResult != null) return validationResult;
      }
      return null;
    };
  }
}
