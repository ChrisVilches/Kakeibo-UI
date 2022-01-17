import 'package:flutter/widgets.dart';

class PaddingTop extends StatelessWidget {
  const PaddingTop({Key? key, required this.child}) : super(key: key);
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: child,
    );
  }
}
