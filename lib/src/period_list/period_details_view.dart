import 'package:flutter/material.dart';
import 'package:kakeibo_ui/src/decoration/date_util.dart';
import 'package:kakeibo_ui/src/decoration/format_util.dart';
import 'package:kakeibo_ui/src/decoration/loading_icon_widget.dart';
import 'package:kakeibo_ui/src/models/day.dart';
import 'package:kakeibo_ui/src/models/period.dart';
import 'package:kakeibo_ui/src/period_list/widgets/burndown_widget.dart';
import 'package:kakeibo_ui/src/period_list/widgets/day_detail_widget.dart';
import 'package:kakeibo_ui/src/period_list/widgets/diff_widget.dart';
import 'package:kakeibo_ui/src/period_list/widgets/period_chart_widget.dart';
import 'package:kakeibo_ui/src/period_list/widgets/projection_widget.dart';
import 'package:kakeibo_ui/src/services/graphql_services.dart';
import 'package:kakeibo_ui/src/services/locator.dart';

// TODO: Move some calculations to a different file.
class PeriodDetailsView extends StatefulWidget {
  static const routeName = '/period_detail';
  const PeriodDetailsView({Key? key}) : super(key: key);

  @override
  PeriodDetailState createState() => PeriodDetailState();
}

class PeriodDetailState extends State<PeriodDetailsView> {
  Period _period = Period();
  final bool animate = true;

  // TODO: These values can also be used for the rendering of the detail view.
  //       That way, the view is not cluttered with calculations and stuff.
  final List<int?> _burndownValues = [];
  final List<int?> _remainingValues = [];
  final List<int?> _projectedValues = [];

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    await _setPeriodDetail();
  }

  void _setChartData() {
    for (int i = 0; i < _period.fullDays.length; i++) {
      _burndownValues.add(burndownBudget(i));

      int? budget = _period.fullDays[i].budget;

      _remainingValues.add(budget);
      _projectedValues.add(budget == null ? null : projection(budget));
    }
  }

  Future<void> _setPeriodDetail() async {
    final arguments = ModalRoute.of(context)!.settings.arguments as Map;
    int periodId = arguments['id'];

    final periodResult =
        await serviceLocator.get<GraphQLServices>().fetchOnePeriod(periodId);

    setState(() {
      _period = periodResult;
    });

    _setChartData();
  }

  String _periodDetailTitle() {
    if (_period.id == null) return 'Period Detail';
    return _period.name!;
  }

  int burndownBudget(int index) {
    return _period.useable() - ((index + 1) * _period.useablePerDay());
  }

  int? diffValue(int index) {
    Day day = _period.fullDays[index];
    if (day.budget == null) return null;

    int rem = remainingUseable(day.budget!)!;
    int burn = burndownBudget(index);

    return rem - burn;
  }

  // TODO: Shouldn't be nullable.
  int? remainingUseable(int? budget) {
    if (budget == null) return null;
    return budget - _period.limit();
  }

  // TODO: Code smell. Shouldn't be nullable.
  int? projection(int? budget) {
    if (budget == null) return null;
    return budget - _period.useablePerDay();
  }

  // TODO: This widget can be put in a different file. Note: the function that returns the widget is still necessary though.
  Widget listItem(BuildContext context, int index) {
    final day = _period.fullDays[index];

    Widget card = Card(
      child: Row(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.all(20),
            child: const Icon(Icons.view_day, color: Colors.pink, size: 24.0),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Column(children: [
              Text(DateUtil.formatDate(day.dayDate!)),
              Text(day.memo, style: const TextStyle(color: Colors.grey)),
            ]),
          ),
          Text(FormatUtil.formatNumberCurrency(day.budget)),
          ProjectionWidget(remainingUseable(day.budget)),
          ProjectionWidget(projection(day.budget)),
          DiffWidget(diffValue(index)),
          BurndownWidget(burndownBudget(index))
        ],
      ),
    );

    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) {
                  return DayDetailWidget(
                      burndown: burndownBudget(index), diff: diffValue(index));
                },
                fullscreenDialog: true));
      },
      child: card,
    );
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
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) {
                        return PeriodChartWidget(
                          burndown: _burndownValues,
                          projected: _projectedValues,
                          remaining: _remainingValues,
                        );
                      },
                      fullscreenDialog: true));
            },
          ),
        ],
      ),
      body: dayList,
      /*body: Column(
        children: [
          Text('Period ID: ${_period.id}'),
          Container(
            child: dayList,
          ),
        ],
      ),*/
    );
  }
}
