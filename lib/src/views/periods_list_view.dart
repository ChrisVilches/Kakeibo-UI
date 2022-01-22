import 'package:flutter/material.dart';
import 'package:kakeibo_ui/src/controllers/navigation_controller.dart';
import 'package:kakeibo_ui/src/decoration/date_util.dart';
import 'package:kakeibo_ui/src/decoration/loading_icon_widget.dart';
import 'package:kakeibo_ui/src/models/period.dart';
import 'package:kakeibo_ui/src/models/extensions/period_queries.dart';
import 'package:kakeibo_ui/src/views/create_period_view.dart';
import 'package:kakeibo_ui/src/views/settings_view.dart';
import 'package:provider/provider.dart';
import 'period_details_view.dart';

class PeriodsListView extends StatefulWidget {
  static const routeName = '/period_list';
  const PeriodsListView({Key? key}) : super(key: key);

  @override
  _PeriodListState createState() => _PeriodListState();
}

class _PeriodListState extends State<PeriodsListView> with SingleTickerProviderStateMixin {
  void _triggerReload() {
    debugPrint("Reloading periods list...");
    setState(() {});
  }

  Widget mainContent(List<Period> periods) {
    return ListView.builder(
      restorationId: 'PeriodsListView',
      itemCount: periods.length,
      itemBuilder: (BuildContext context, int index) {
        final period = periods[index];

        List<String> dateRange = DateUtil.formatDayRanges(period.dateFrom!, period.dateTo!);

        return ListTile(
          title: Text('${period.name}'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [const SizedBox(height: 5), Text('${dateRange[0]} ~ ${dateRange[1]}')],
          ),
          leading: const Icon(Icons.monetization_on_outlined, color: Colors.pink, size: 24.0),
          onTap: () {
            Provider.of<NavigationController>(context, listen: false).loadPeriod(period.id!);

            Navigator.of(context)
                .pushNamed(PeriodDetailsView.routeName)
                .then((_) => _triggerReload());
          },
        );
      },
    );
  }

  Widget empty() {
    return const Center(
      child: Text("No periods yet!", style: TextStyle(fontSize: 20)),
    );
  }

  Widget periodsListView(BuildContext context, AsyncSnapshot<List<Period>> snapshot) {
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
                _triggerReload();
              }
            },
            tooltip: 'Create new period',
            child: const Icon(Icons.add),
          ),
        )
      ],
    );

    List<Period> periods = snapshot.data!;

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
      body: periods.isEmpty ? empty() : mainContent(periods),
      floatingActionButton: buttonRow,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: PeriodQueries.fetchAll(),
      builder: (BuildContext context, AsyncSnapshot<List<Period>> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return const Center(child: LoadingIcon());
          default:
            if (snapshot.hasError) {
              return const Text("Error");
            } else {
              return periodsListView(context, snapshot);
            }
        }
      },
    );
  }
}
