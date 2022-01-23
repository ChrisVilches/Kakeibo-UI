import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kakeibo_ui/src/decoration/loading_icon_widget.dart';
import 'package:kakeibo_ui/src/widgets/misc/app_logo_widget.dart';

class SplashScreenView extends StatefulWidget {
  static const routeName = '/splash_screen';

  const SplashScreenView({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreenView> {
  final splashDelay = 2;
  Timer? _timer;

  @override
  initState() {
    super.initState();

    _timer = Timer(
      Duration(seconds: splashDelay),
      () async => {Navigator.pop(context)},
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black12,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            AppLogoWidget(shadow: true),
            LoadingIcon(),
          ],
        ),
      ),
    );
  }
}
