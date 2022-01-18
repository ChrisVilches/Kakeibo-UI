import 'package:flutter/material.dart';
import 'package:kakeibo_ui/src/decoration/form_validators.dart';
import 'package:kakeibo_ui/src/exceptions/incorrect_login_exception.dart';
import 'package:kakeibo_ui/src/home_view.dart';
import 'package:kakeibo_ui/src/services/locator.dart';
import 'package:kakeibo_ui/src/services/user_service.dart';
import 'decoration/extra_padding_widget.dart';
import 'decoration/helpers.dart';
import 'decoration/loading_icon_widget.dart';
import 'misc_widgets/app_logo_widget.dart';

class LoginView extends StatefulWidget {
  static const routeName = '/login';

  const LoginView({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  String _emailValue = "";
  String _passwordValue = "";
  bool _obscureText = true;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      await serviceLocator.get<UserService>().login(_emailValue, _passwordValue);
    } on IncorrectLoginException catch (e) {
      Helpers.simpleSnackbar(context, e.toString());
      setState(() => _loading = false);
      return;
    }

    Helpers.simpleSnackbar(context, "You logged in successfully!");
    Navigator.of(context).pushReplacementNamed(HomeView.routeName);
  }

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Widget emailInput() => TextFormField(
        autofocus: true,
        enableSuggestions: true,
        autocorrect: true,
        onChanged: (text) => {
          setState(() {
            _emailValue = text;
          })
        },
        validator: FormValidators.pipe([
          FormValidators.requiredField,
          FormValidators.mustBeEmail,
        ]),
        decoration: const InputDecoration(
            labelText: 'E-mail',
            icon: Padding(padding: EdgeInsets.only(top: 15.0), child: Icon(Icons.email))),
      );

  Widget passwordInput() => TextFormField(
        decoration: InputDecoration(
          labelText: 'Password',
          icon: const Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Icon(Icons.lock),
          ),
          suffixIcon: IconButton(
            icon: Icon(_obscureText ? Icons.remove_red_eye : Icons.visibility_off_rounded),
            onPressed: _toggle,
          ),
        ),
        validator: FormValidators.requiredField,
        obscureText: _obscureText,
        onChanged: (text) => {
          setState(() {
            _passwordValue = text;
          })
        },
      );

  Widget submitButton() => _loading
      ? const LoadingIcon()
      : ElevatedButton(
          onPressed: _loading ? null : _submitForm,
          child: const Text("Sign-in"),
        );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Form(
          key: _formKey,
          child: ExtraPadding(
            child: Column(
              children: [
                const AppLogoWidget(),
                emailInput(),
                passwordInput(),
                const SizedBox(height: 50),
                submitButton()
              ],
            ),
          ),
        ),
      ),
    );
  }
}
