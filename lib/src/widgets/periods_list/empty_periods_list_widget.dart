import 'package:flutter/widgets.dart';

class EmptyPeriodsListWidget extends StatelessWidget {
  const EmptyPeriodsListWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('No periods yet!', style: TextStyle(fontSize: 20)),
    );
  }
}
