import 'package:flutter/widgets.dart';

class ExtraPadding extends StatelessWidget {
  const ExtraPadding({Key? key, required this.child}) : super(key: key);
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 20.0, left: 20.0),
      child: child,
    );
  }
}
