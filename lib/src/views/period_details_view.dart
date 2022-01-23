import 'package:flutter/material.dart';
import 'package:kakeibo_ui/src/models/navigation_store.dart';
import 'package:kakeibo_ui/src/decoration/loading_icon_widget.dart';
import 'package:kakeibo_ui/src/models/period.dart';
import 'package:kakeibo_ui/src/widgets/day_list_item_widget.dart';
import 'package:kakeibo_ui/src/widgets/period_detail/configure_reminder_dialog_widget.dart';
import 'package:kakeibo_ui/src/widgets/scaffolds/period_chart_scaffold.dart';
import 'package:kakeibo_ui/src/widgets/scaffolds/period_config_scaffold.dart';
import 'package:provider/provider.dart';

class PeriodDetailsView extends StatefulWidget {
  static const routeName = '/period_detail';

  const PeriodDetailsView({Key? key}) : super(key: key);

  @override
  _PeriodDetailsState createState() => _PeriodDetailsState();
}

class _PeriodDetailsState extends State<PeriodDetailsView> {
  Period? _period;

  void _showReminderConfig(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ConfigureReminderDialogWidget(onPressOk: () => _openConfigWidgetModal(context));
      },
    );
  }

  bool providerHasDifferentPeriod() {
    NavigationStore nav = Provider.of<NavigationStore>(context);
    return nav.hasPeriod() && (_period == null || _period!.id != nav.currentPeriod!.id);
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();

    if (!providerHasDifferentPeriod()) return;

    _period = Provider.of<NavigationStore>(context, listen: false).currentPeriod!;

    if (!_period!.fullyConfigured()) {
      // https://stackoverflow.com/questions/58027568/another-exception-was-thrown-packageflutter-src-widgets-navigator-dart-fail
      Future.delayed(Duration.zero, () => _showReminderConfig(context));
    }
  }

  void _openConfigWidgetModal(BuildContext context) async {
    await Navigator.push<bool?>(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) {
          return PeriodConfigScaffold(period: _period!);
        },
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (Provider.of<NavigationStore>(context).loading) {
      return const Center(child: LoadingIcon());
    }

    Period period = Provider.of<NavigationStore>(context).currentPeriod!;

    debugPrint("Period detail (ID: ${period.id})");

    Widget dayList = ListView.builder(
      restorationId: 'PeriodDetailsView_DayList',
      itemCount: period.fullDays.length,
      itemBuilder: (BuildContext context, int index) => DayListItemWidget(
        day: Provider.of<NavigationStore>(context).currentPeriod!.fullDays[index],
        dayDetailModalClosedCallback: () {
          debugPrint("Refreshing period detail...");
          Provider.of<NavigationStore>(context, listen: false).reloadPeriod();
        },
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(period.name!),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _openConfigWidgetModal(context),
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => PeriodChartScaffold(period),
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
