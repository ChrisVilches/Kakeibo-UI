import 'package:flutter/widgets.dart';
import 'package:kakeibo_ui/src/exceptions/incorrect_login_exception.dart';
import 'package:kakeibo_ui/src/services/locator.dart';
import 'package:kakeibo_ui/src/services/user_service.dart';

class LoginController with ChangeNotifier {
  final _formKey = GlobalKey<FormState>();
  String _emailValue = '';
  String _passwordValue = '';
  bool _obscureText = true;
  bool _loading = false;

  bool get loading => _loading;
  bool get obscureText => _obscureText;
  GlobalKey<FormState> get formKey => _formKey;

  void onChangeEmail(String text) {
    _emailValue = text;
    notifyListeners();
  }

  void onChangePassword(String text) {
    _passwordValue = text;
    notifyListeners();
  }

  void toggle() {
    _obscureText = !_obscureText;
    notifyListeners();
  }

  Future<bool> submitForm() async {
    if (!_formKey.currentState!.validate()) return false;

    _loading = true;
    notifyListeners();

    try {
      await serviceLocator.get<UserService>().login(_emailValue, _passwordValue);
    } on IncorrectLoginException {
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }

    return true;
  }
}
