import 'package:flutter/material.dart';
import 'package:kakeibo_ui/src/create_period/create_period_view.dart';
import 'package:kakeibo_ui/src/decoration/date_util.dart';
import 'package:kakeibo_ui/src/decoration/loading_icon_widget.dart';
import 'package:kakeibo_ui/src/models/period.dart';
import 'package:kakeibo_ui/src/services/graphql_services.dart';
import 'package:kakeibo_ui/src/services/locator.dart';
import 'package:kakeibo_ui/src/settings/settings_view.dart';

import 'period_details_view.dart';

class PeriodsListView extends StatefulWidget {
  static const routeName = '/period_list';
  const PeriodsListView({Key? key}) : super(key: key);

  @override
  _PeriodListState createState() => _PeriodListState();
}

class _PeriodListState extends State<PeriodsListView> {
  bool _loading = true;

  List<Period> _periods = [];

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    await _loadPeriodList();
  }

  Future<void> _loadPeriodList() async {
    setState(() {
      _loading = true;
    });

    debugPrint("Loading period list...");

    List<Period> result = await serviceLocator.get<GraphQLServices>().fetchPeriods();

    setState(() {
      _periods = result;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: LoadingIcon());

    Widget buttonRow = Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 10.0),
          child: FloatingActionButton(
            onPressed: () async {
              bool shouldRefresh = (await Navigator.pushNamed(
                    context,
                    CreatePeriodView.routeName,
                  ) as bool?) ??
                  false;

              if (shouldRefresh) {
                _loadPeriodList();
              }
            },
            tooltip: 'Create new period',
            child: const Icon(Icons.add),
          ),
        )
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kakeibo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              Navigator.restorablePushNamed(context, SettingsView.routeName);
            },
          ),
        ],
      ),
      body: ListView.builder(
        restorationId: 'PeriodsListView',
        itemCount: _periods.length,
        itemBuilder: (BuildContext context, int index) {
          final period = _periods[index];

          List<String> dateRange = DateUtil.formatDayRanges(period.dateFrom!, period.dateTo!);

          return ListTile(
            title: Text('${period.name}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [const SizedBox(height: 5), Text('${dateRange[0]} ~ ${dateRange[1]}')],
            ),
            leading: const Icon(Icons.monetization_on_outlined, color: Colors.pink, size: 24.0),
            onTap: () async {
              await Navigator.pushNamed(context, PeriodDetailsView.routeName,
                  arguments: {'id': period.id});

              // TODO: Probably not very good to reload the period list here. (it's easy to forget, and there are many places)
              // A lifecycle event would be a lot better. But how?
              _loadPeriodList();
            },
          );
        },
      ),
      floatingActionButton: buttonRow,
    );
  }
}
