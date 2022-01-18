import 'package:flutter/material.dart';
import 'package:kakeibo_ui/src/login_view.dart';
import 'package:kakeibo_ui/src/period_list/periods_list_view.dart';
import 'package:kakeibo_ui/src/services/locator.dart';
import 'package:kakeibo_ui/src/services/user_service.dart';

class HomeView extends StatefulWidget {
  static const routeName = '/';

  const HomeView({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<HomeView> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  bool _isLoggedIn() {
    return serviceLocator.get<UserService>().hasToken();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoggedIn() ? const PeriodsListView() : const LoginView();
  }
}
