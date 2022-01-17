import 'package:flutter/material.dart';
import 'package:kakeibo_ui/src/decoration/loading_icon_widget.dart';
import 'package:kakeibo_ui/src/models/period.dart';
import 'package:kakeibo_ui/src/period_list/widgets/day_list_item_widget.dart';
import 'package:kakeibo_ui/src/period_list/widgets/period_chart_widget.dart';
import 'package:kakeibo_ui/src/period_list/widgets/period_config_widget.dart';
import 'package:kakeibo_ui/src/services/graphql_services.dart';
import 'package:kakeibo_ui/src/services/locator.dart';
import 'package:kakeibo_ui/src/services/table_calculator.dart';

// TODO: Not sure about all the nesting, but it's OK probably, since Dart has "required" keyword,
//       which makes it easier not to forget a callback or something like that.

class PeriodDetailsView extends StatefulWidget {
  static const routeName = '/period_detail';
  const PeriodDetailsView({Key? key}) : super(key: key);

  @override
  PeriodDetailState createState() => PeriodDetailState();
}

class PeriodDetailState extends State<PeriodDetailsView> {
  Period _period = Period();
  late TableCalculator _table;

  final bool animate = true;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    await _setPeriodDetail();

    if (_shouldShowReminderConfig()) {
      _showReminderConfig();
    }
  }

  void _openConfigWidgetModal() async {
    bool shouldRefresh = (await Navigator.push<bool?>(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) {
              return PeriodConfigWidget(period: _period);
            },
            fullscreenDialog: true,
          ),
        ) ??
        false);

    if (shouldRefresh) {
      debugPrint(
          "Refreshing period detail (because submitted the form in config widget)...");
      _setPeriodDetail();
    }
  }

  void _showReminderConfig() {
    Widget okButton = TextButton(
      child: const Text("Configure"),
      onPressed: () {
        // Remove alert first.
        Navigator.of(context).pop();
        _openConfigWidgetModal();
      },
    );

    Widget cancelButton = TextButton(
      child: const Text("Cancel"),
      style:
          ButtonStyle(foregroundColor: MaterialStateProperty.all(Colors.grey)),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    AlertDialog alert = AlertDialog(
      title: const Text("Please configure this period correctly"),
      content: const Text(
          "It seems this period is missing some configurations. Configure now?"),
      actions: [cancelButton, okButton],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  bool _shouldShowReminderConfig() {
    return _period.salary! == 0 ||
        _period.initialMoney! == 0 ||
        _period.dailyExpenses! == 0;
  }

  Future<void> _setPeriodDetail() async {
    final arguments = ModalRoute.of(context)!.settings.arguments as Map;
    int periodId = arguments['id'];

    final periodResult =
        await serviceLocator.get<GraphQLServices>().fetchOnePeriod(periodId);

    setState(() {
      _period = periodResult;
    });

    _table = TableCalculator(_period);
  }

  String _periodDetailTitle() {
    if (_period.id == null) return 'Period Detail';
    return _period.name!;
  }

  Widget listItem(BuildContext context, int index) {
    final day = _period.fullDays[index];

    return DayListItemWidget(
        period: _period,
        day: day,
        burndown: _table.burndown[index],
        projection: _table.projections[index],
        remaining: _table.remaining[index],
        diff: _table.diff[index],
        dayDetailModalClosedCallback: () {
          debugPrint("Refreshing period detail...");
          _setPeriodDetail();
        });
  }

  @override
  Widget build(BuildContext context) {
    if (_period.id == null) {
      return const Center(child: LoadingIcon());
    }

    debugPrint("ID: ${_period.id}");
    debugPrint("days amount: ${_period.fullDays.length}");
    debugPrint("initial money: ${_period.initialMoney}");
    debugPrint("salary: ${_period.salary}");
    debugPrint("savingsPercentage: ${_period.savingsPercentage}");
    debugPrint("useable: ${_period.useable()}");
    debugPrint("limit: ${_period.limit()}");
    debugPrint("useable per day: ${_period.useablePerDay()}");

    Widget dayList = ListView.builder(
      restorationId: 'PeriodDetailsView_DayList',
      itemCount: _period.fullDays.length,
      itemBuilder: listItem,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(_periodDetailTitle()),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _openConfigWidgetModal,
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => PeriodChartWidget(_period),
                  fullscreenDialog: true,
                ),
              );
            },
          ),
        ],
      ),
      body: dayList,
    );
  }
}
