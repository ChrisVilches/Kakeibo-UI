import 'package:flutter/material.dart';

/// Displays detailed information about a SampleItem.
class PeriodDetailsView extends StatelessWidget {
  const PeriodDetailsView({Key? key}) : super(key: key);

  static const routeName = '/period_detail';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Period Detail'),
      ),
      body: const Center(
        child: Text('More Information Here (edit money info, etc)'),
      ),
    );
  }
}
