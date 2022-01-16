import 'package:flutter/widgets.dart';

class PaddingBottom extends StatelessWidget {
  const PaddingBottom({Key? key, required this.child}) : super(key: key);
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: child,
    );
  }
}
