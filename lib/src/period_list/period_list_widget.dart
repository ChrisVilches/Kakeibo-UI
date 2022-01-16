import 'package:flutter/material.dart';
import 'package:kakeibo_ui/src/services/graphql_client.dart';
import 'package:kakeibo_ui/src/services/locator.dart';

import '../create_period/create_period_widget.dart';
import '../settings/settings_view.dart';
import 'sample_item_details_view.dart';

class PeriodListWidget extends StatefulWidget {
  static const routeName = '/';
  const PeriodListWidget({Key? key}) : super(key: key);

  @override
  PeriodListState createState() => PeriodListState();
}

// TODO: Is this class naming (state and widget) correct?
//       it probably is, considering that State extends State<> and
//       widget extends StatefulWidget
class PeriodListState extends State<PeriodListWidget> {
  bool _loading = true;

  List<dynamic> _periods = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setPeriodList();
  }

  void setPeriodList() {
    setState(() {
      _loading = true;
    });

    Future<List<dynamic>> periodsData =
        serviceLocator.get<GraphQLServices>().fetchPeriods();

    periodsData.then((result) {
      setState(() {
        _periods = result;
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      // TODO: This is dumb
      return const Text("Loading...");
    }

    Widget buttonRow = Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: FloatingActionButton(
              onPressed: () {
                Navigator.restorablePushNamed(
                  context,
                  CreatePeriodWidget.routeName,
                );
              },
              tooltip: 'Increment',
              child: const Icon(Icons.add),
            )),
        FloatingActionButton(
          onPressed: () {},
          tooltip: 'Alarm',
          child: const Icon(Icons.access_alarms),
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kakeibo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              // Navigate to the settings page. If the user leaves and returns
              // to the app after it has been killed while running in the
              // background, the navigation stack is restored.
              Navigator.restorablePushNamed(context, SettingsView.routeName);
            },
          ),
        ],
      ),
      body: ListView.builder(
        // Providing a restorationId allows the ListView to restore the
        // scroll position when a user leaves and returns to the app after it
        // has been killed while running in the background.
        restorationId: 'PeriodListView',
        itemCount: _periods.length,
        itemBuilder: (BuildContext context, int index) {
          final period = _periods[index];

          return ListTile(
              title: Text('${period['name']}'),
              leading: const Icon(Icons.monetization_on_outlined,
                  color: Colors.pink, size: 24.0),
              onTap: () {
                Navigator.restorablePushNamed(
                  context,
                  SampleItemDetailsView.routeName,
                );
              });
        },
      ),
      floatingActionButton: buttonRow,
    );
  }
}
