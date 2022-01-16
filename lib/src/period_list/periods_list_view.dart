import 'package:flutter/material.dart';
import 'package:kakeibo_ui/src/decoration/date_util.dart';
import 'package:kakeibo_ui/src/models/period.dart';
import '../decoration/loading_icon_widget.dart';
import '../services/graphql_services.dart';
import '../services/locator.dart';
import '../create_period/create_period_view.dart';
import '../settings/settings_view.dart';
import 'period_details_view.dart';

class PeriodsListView extends StatefulWidget {
  static const routeName = '/';
  const PeriodsListView({Key? key}) : super(key: key);

  @override
  PeriodListState createState() => PeriodListState();
}

// TODO: Is this class naming (state and widget) correct?
//       it probably is, considering that State extends State<> and
//       widget extends StatefulWidget
class PeriodListState extends State<PeriodsListView> {
  bool _loading = true;

  List<Period> _periods = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setPeriodList();
  }

  void setPeriodList() {
    setState(() {
      _loading = true;
    });

    Future<List<Period>> periodsData =
        serviceLocator.get<GraphQLServices>().fetchPeriods();

    periodsData.then((result) {
      setState(() {
        _periods = result;
        _loading = false;
      });
    });
  }

  // TODO: Does not work
  Future<void> _pullRefresh() async {
    debugPrint("REFRESHING.....");
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: LoadingIcon());
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
                  CreatePeriodView.routeName,
                );
              },
              tooltip: 'Increment',
              child: const Icon(Icons.add),
            ))
      ],
    );

    // TODO: In the list, show both dates, that way it'd be easier.
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
      body: RefreshIndicator(
        onRefresh: _pullRefresh,
        child: ListView.builder(
          // Providing a restorationId allows the ListView to restore the
          // scroll position when a user leaves and returns to the app after it
          // has been killed while running in the background.
          restorationId: 'PeriodsListView',
          itemCount: _periods.length,
          itemBuilder: (BuildContext context, int index) {
            final period = _periods[index];

            return ListTile(
                title: Text('${period.name}'),
                subtitle: Text(
                    '${DateUtil.formatDate(period.dateFrom!)} - ${DateUtil.formatDate(period.dateTo!)}'),
                leading: const Icon(Icons.monetization_on_outlined,
                    color: Colors.pink, size: 24.0),
                onTap: () {
                  Navigator.restorablePushNamed(
                      context, PeriodDetailsView.routeName,
                      arguments: {'id': period.id});
                });
          },
        ),
      ),
      floatingActionButton: buttonRow,
    );
  }
}
