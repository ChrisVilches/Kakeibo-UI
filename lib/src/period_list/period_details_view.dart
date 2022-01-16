import 'package:flutter/material.dart';
import 'package:kakeibo_ui/src/decoration/loading_icon_widget.dart';
import 'package:kakeibo_ui/src/models/day.dart';
import 'package:kakeibo_ui/src/models/period.dart';
import 'package:kakeibo_ui/src/period_list/widgets/day_list_item_widget.dart';
import 'package:kakeibo_ui/src/period_list/widgets/period_chart_widget.dart';
import 'package:kakeibo_ui/src/services/graphql_services.dart';
import 'package:kakeibo_ui/src/services/locator.dart';

// TODO: Not sure about all the nesting, but it's OK probably, since Dart has "required" keyword,
//       which makes it easier not to forget a callback or something like that.

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
    _burndownValues.clear();
    _remainingValues.clear();
    _projectedValues.clear();

    for (int i = 0; i < _period.fullDays.length; i++) {
      _burndownValues.add(burndownBudget(i));

      int? budget = _period.fullDays[i].budget;

      _remainingValues.add(remainingUseable(budget));
      _projectedValues.add(budget == null ? null : projection(i));
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

  // TODO: This is wrong. The correct way to do it is by:
  // If the user has filled a day (budget), then start from there predicting the next days.
  // Remove the projection (from the UI, charts, etc) if the budget has been filled (no need to predict).
  int projection(int index) {
    return _period.useable() - (index * _period.useablePerDay());
  }

  Widget listItem(BuildContext context, int index) {
    final day = _period.fullDays[index];

    return DayListItemWidget(
        period: _period,
        day: day,
        burndown: burndownBudget(index),
        projection: projection(index),
        remaining: remainingUseable(day.budget),
        diff: diffValue(index),
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
                  fullscreenDialog: true,
                ),
              );
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
