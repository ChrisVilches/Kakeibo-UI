import 'package:flutter/material.dart';
import 'package:kakeibo_ui/src/controllers/login_controller.dart';
import 'package:kakeibo_ui/src/decoration/extra_padding_widget.dart';
import 'package:kakeibo_ui/src/decoration/form_validators.dart';
import 'package:kakeibo_ui/src/decoration/loading_icon_widget.dart';
import 'package:kakeibo_ui/src/exceptions/incorrect_login_exception.dart';
import 'package:kakeibo_ui/src/services/locator.dart';
import 'package:kakeibo_ui/src/widgets/misc/app_logo_widget.dart';
import 'package:kakeibo_ui/src/services/snackbar_service.dart';
import 'package:kakeibo_ui/src/views/home_view.dart';
import 'package:provider/provider.dart';

class LoginView extends StatelessWidget {
  static const routeName = '/login';

  const LoginView({Key? key}) : super(key: key);

  void _submitForm(BuildContext context) async {
    try {
      if (await Provider.of<LoginController>(context, listen: false).submitForm()) {
        serviceLocator.get<SnackbarService>().simpleSnackbar("You logged in successfully!");
        Navigator.of(context).pushReplacementNamed(HomeView.routeName);
      }
    } on IncorrectLoginException catch (e) {
      serviceLocator.get<SnackbarService>().simpleSnackbar(e.toString());
    }
  }

  Widget emailInput(LoginController ctrl) => TextFormField(
        autofocus: true,
        enableSuggestions: true,
        autocorrect: true,
        onChanged: ctrl.onChangeEmail,
        validator: FormValidators.pipe([
          FormValidators.requiredField,
          FormValidators.mustBeEmail,
        ]),
        decoration: const InputDecoration(
            labelText: 'E-mail',
            icon: Padding(padding: EdgeInsets.only(top: 15.0), child: Icon(Icons.email))),
      );

  Widget passwordInput(LoginController ctrl) => TextFormField(
        decoration: InputDecoration(
          labelText: 'Password',
          icon: const Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Icon(Icons.lock),
          ),
          suffixIcon: IconButton(
            icon: Icon(ctrl.obscureText ? Icons.remove_red_eye : Icons.visibility_off_rounded),
            onPressed: ctrl.toggle,
          ),
        ),
        validator: FormValidators.requiredField,
        obscureText: ctrl.obscureText,
        onChanged: ctrl.onChangePassword,
      );

  Widget submitButton(BuildContext context) {
    return Consumer<LoginController>(builder: (context, ctrl, _) {
      return ctrl.loading
          ? const LoadingIcon()
          : ElevatedButton(
              onPressed: ctrl.loading ? null : () => _submitForm(context),
              child: const Text("Sign-in"),
            );
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LoginController>(
      create: (_) => LoginController(),
      builder: (context, __) {
        final ctrl = Provider.of<LoginController>(context, listen: false);

        return Scaffold(
          body: Center(
            child: Form(
              key: ctrl.formKey,
              child: ExtraPadding(
                child: Column(
                  children: [
                    const AppLogoWidget(),
                    emailInput(ctrl),
                    passwordInput(ctrl),
                    const SizedBox(height: 50),
                    submitButton(context)
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
