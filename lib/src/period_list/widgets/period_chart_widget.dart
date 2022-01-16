import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class PeriodChartWidget extends StatelessWidget {
  final List<int?> burndown;
  final List<int?> remaining;
  final List<int?> projected;

  const PeriodChartWidget(
      {Key? key,
      required this.burndown,
      required this.remaining,
      required this.projected})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Chart")),
        body: _BarChartWidget(
          burndownValues: burndown,
          remainingValues: remaining,
          projectedValues: projected,
        ));
  }
}

class _BarChartWidget extends StatelessWidget {
  List<charts.Series<dynamic, String>> _seriesList = [];
  final bool _animate = true;

  List<int?> burndownValues;
  List<int?> remainingValues;
  List<int?> projectedValues;

  _BarChartWidget(
      {required this.burndownValues,
      required this.remainingValues,
      required this.projectedValues}) {
    assert(burndownValues.length == remainingValues.length);
    assert(projectedValues.length == remainingValues.length);
    _setSeries();
  }

  void _setSeries() {
    final int n = burndownValues.length;

    List<_Bar> projectionData = [];
    List<_Bar> burndownData = [];
    List<_Bar> remainingData = [];

    // TODO: Add correct labels (if it gets too crowded, then remove them).
    for (int i = 0; i < n; i++) {
      projectionData.add(_Bar(i.toString(), projectedValues[i]));
      burndownData.add(_Bar(i.toString(), burndownValues[i]));
      remainingData.add(_Bar(i.toString(), remainingValues[i]));
    }

    _seriesList = [
      charts.Series<_Bar, String>(
          id: 'Projection',
          colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
          domainFn: (_Bar sales, _) => sales.label,
          measureFn: (_Bar sales, _) => sales.value,
          data: projectionData),
      charts.Series<_Bar, String>(
          id: 'Burndown',
          colorFn: (_, __) => charts.MaterialPalette.gray.shadeDefault,
          domainFn: (_Bar sales, _) => sales.label,
          measureFn: (_Bar sales, _) => sales.value,
          data: burndownData),
      charts.Series<_Bar, String>(
          id: 'Remaining',
          colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
          domainFn: (_Bar sales, _) => sales.label,
          measureFn: (_Bar sales, _) => sales.value,
          data: remainingData)
    ];
  }

  @override
  Widget build(BuildContext context) {
    return charts.OrdinalComboChart(
      _seriesList,
      animate: _animate,
      behaviors: [new charts.SeriesLegend()],
      defaultRenderer: charts.BarRendererConfig(
          groupingType: charts.BarGroupingType.grouped),
    );
  }
}

class _Bar {
  final String label;
  final int? value;

  const _Bar(this.label, this.value);
}
