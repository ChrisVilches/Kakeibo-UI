import 'package:flutter/material.dart';
import 'package:kakeibo_ui/src/decoration/loading_icon_widget.dart';
import 'package:kakeibo_ui/src/models/day_data.dart';
import 'package:kakeibo_ui/src/models/extensions/period_queries.dart';
import 'package:kakeibo_ui/src/models/period.dart';
import 'package:kakeibo_ui/src/services/table_calculator.dart';
import 'package:kakeibo_ui/src/widgets/day_list_item_widget.dart';
import 'package:kakeibo_ui/src/widgets/scaffolds/period_chart_scaffold.dart';
import 'package:kakeibo_ui/src/widgets/scaffolds/period_config_scaffold.dart';
import 'package:provider/provider.dart';

class PeriodDetailsView extends StatefulWidget {
  static const routeName = '/period_detail';
  const PeriodDetailsView({Key? key}) : super(key: key);

  @override
  PeriodDetailState createState() => PeriodDetailState();
}

class PeriodDetailState extends State<PeriodDetailsView> {
  Period _period = Period();
  late List<DayData> _dataTable;

  final bool animate = true;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    debugPrint("Loading period detail...");
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
              return PeriodConfigScaffold(period: _period);
            },
            fullscreenDialog: true,
          ),
        ) ??
        false);

    if (shouldRefresh) {
      debugPrint("Refreshing period detail (because submitted the form in config widget)...");
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
      style: ButtonStyle(foregroundColor: MaterialStateProperty.all(Colors.grey)),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    AlertDialog alert = AlertDialog(
      title: const Text("Please configure this period correctly"),
      content: const Text("It seems this period is missing some configurations. Configure now?"),
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
    return _period.salary! == 0 || _period.initialMoney! == 0 || _period.dailyExpenses! == 0;
  }

  Future<void> _setPeriodDetail() async {
    final arguments = ModalRoute.of(context)!.settings.arguments as Map;
    int periodId = arguments['id'];

    final periodResult = await PeriodQueries.fetchOne(periodId);

    setState(() {
      _period = periodResult;
    });

    _dataTable = TableCalculator.obtainData(_period);
  }

  String _periodDetailTitle() {
    if (_period.id == null) return 'Period Detail';
    return _period.name!;
  }

  Widget listItem(BuildContext context, int index) {
    Widget item = DayListItemWidget(dayDetailModalClosedCallback: () {
      debugPrint("Refreshing period detail...");
      _setPeriodDetail();
    });

    return MultiProvider(
      providers: [
        Provider<Period>(create: (_) => _period),
        Provider<DayData>(create: (_) => _dataTable[index]),
      ],
      builder: (BuildContext context, Widget? _) => item,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_period.id == null) {
      return const Center(child: LoadingIcon());
    }

    debugPrint("▶  Period detail (ID: ${_period.id})");
    debugPrint("   days amount: ${_period.fullDays.length}");
    debugPrint("   initial money: ${_period.initialMoney}");
    debugPrint("   salary: ${_period.salary}");
    debugPrint("   savingsPercentage: ${_period.savingsPercentage}");
    debugPrint("   useable: ${_period.useable()}");
    debugPrint("   limit: ${_period.limit()}");
    debugPrint("   useable per day: ${_period.useablePerDay()}");

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
                  builder: (BuildContext context) => PeriodChartScaffold(_period),
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
