import 'package:flutter/material.dart';
import 'package:kakeibo_ui/src/controllers/navigation_controller.dart';
import 'package:kakeibo_ui/src/decoration/loading_icon_widget.dart';
import 'package:kakeibo_ui/src/models/period.dart';
import 'package:kakeibo_ui/src/widgets/day_list_item_widget.dart';
import 'package:kakeibo_ui/src/widgets/scaffolds/period_chart_scaffold.dart';
import 'package:kakeibo_ui/src/widgets/scaffolds/period_config_scaffold.dart';
import 'package:provider/provider.dart';

// TODO: Divide widget (it's too long).

class PeriodDetailsView extends StatefulWidget {
  static const routeName = '/period_detail';
  const PeriodDetailsView({Key? key}) : super(key: key);

  @override
  PeriodDetailState createState() => PeriodDetailState();
}

class PeriodDetailState extends State<PeriodDetailsView> {
  Period _period = Period();

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();

    int? currPeriodId = _period.id;

    NavigationController navigationCtrl = Provider.of<NavigationController>(context);
    if (!navigationCtrl.hasPeriod()) return;
    debugPrint("Period loaded (using the navigation controller provider)");

    _period = navigationCtrl.currentPeriod!;

    if (currPeriodId == _period.id) {
      debugPrint("Period has not changed. Do not show reminder dialog");
      return;
    }

    if (_shouldShowReminderConfig()) {
      // https://stackoverflow.com/questions/58027568/another-exception-was-thrown-packageflutter-src-widgets-navigator-dart-fail
      Future.delayed(Duration.zero, _showReminderConfig);
    }
  }

  void _openConfigWidgetModal() async {
    await Navigator.push<bool?>(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) {
          return PeriodConfigScaffold(period: _period);
        },
        fullscreenDialog: true,
      ),
    );
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

  String _periodDetailTitle() {
    if (_period.id == null) return 'Period Detail';
    return _period.name!;
  }

  Widget listItem(BuildContext context, int index) {
    return DayListItemWidget(
        day: Provider.of<NavigationController>(context).currentPeriod!.fullDays[index],
        dayDetailModalClosedCallback: () {
          debugPrint("Refreshing period detail...");
          Provider.of<NavigationController>(context).reloadPeriod();
        });
  }

  @override
  Widget build(BuildContext context) {
    if (Provider.of<NavigationController>(context).loading) {
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
