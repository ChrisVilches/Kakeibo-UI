import 'package:flutter/material.dart';
import 'package:kakeibo_ui/src/decoration/loading_icon_widget.dart';
import 'package:kakeibo_ui/src/models/extensions/period_queries.dart';
import 'package:kakeibo_ui/src/models/period.dart';
import 'package:kakeibo_ui/src/views/create_period_view.dart';
import 'package:kakeibo_ui/src/views/settings_view.dart';
import 'package:kakeibo_ui/src/widgets/periods_list/empty_periods_list_widget.dart';
import 'package:kakeibo_ui/src/widgets/periods_list/periods_list_main_widget.dart';
import 'package:kakeibo_ui/src/widgets/scaffolds/generic_error_scaffold.dart';

class PeriodsListView extends StatefulWidget {
  static const routeName = '/period_list';
  const PeriodsListView({Key? key}) : super(key: key);

  @override
  _PeriodListState createState() => _PeriodListState();
}

class _PeriodListState extends State<PeriodsListView> with SingleTickerProviderStateMixin {
  void _triggerReload() {
    debugPrint('Reloading periods list...');
    setState(() {});
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
              debugPrint(snapshot.error.toString());
              return GenericErrorScaffold();
            } else {
              return _PeriodList(snapshot: snapshot, triggerReload: _triggerReload);
            }
        }
      },
    );
  }
}

class _PeriodList extends StatelessWidget {
  final AsyncSnapshot<List<Period>> _snapshot;
  final Function _triggerReload;

  const _PeriodList(
      {Key? key, required AsyncSnapshot<List<Period>> snapshot, required Function triggerReload})
      : _snapshot = snapshot,
        _triggerReload = triggerReload,
        super(key: key);

  @override
  Widget build(BuildContext context) {
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

    List<Period> periods = _snapshot.data!;

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
      body: periods.isEmpty
          ? const EmptyPeriodsListWidget()
          : PeriodsListMainWidget(periods: periods, onBackFromDetailView: _triggerReload),
      floatingActionButton: buttonRow,
    );
  }
}
