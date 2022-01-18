import 'package:flutter/material.dart';

class AppLogoWidget extends StatelessWidget {
  final bool shadow;

  const AppLogoWidget({Key? key, this.shadow = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double unitHeightValue = MediaQuery.of(context).size.height * 0.01;
    double multiplier = 7;

    return Text('KAKEIBO',
        softWrap: false,
        style: TextStyle(
            shadows: shadow
                ? const <Shadow>[
                    Shadow(
                      offset: Offset(10.0, 10.0),
                      blurRadius: 3.0,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ]
                : [],
            fontFamily: 'BillionDreams',
            fontSize: multiplier * unitHeightValue));
  }
}
