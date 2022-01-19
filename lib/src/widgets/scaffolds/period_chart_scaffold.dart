import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:kakeibo_ui/src/decoration/extra_padding_widget.dart';
import 'package:kakeibo_ui/src/models/day_data.dart';
import 'package:kakeibo_ui/src/models/period.dart';
import 'package:kakeibo_ui/src/services/table_calculator.dart';

class PeriodChartScaffold extends StatelessWidget {
  final Period _period;

  const PeriodChartScaffold(this._period, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text("Chart")), body: _BarChartWidget(_period));
  }
}

class _BarChartWidget extends StatelessWidget {
  late final List<charts.Series<dynamic, String>> _seriesList;
  final bool _animate = true;
  final Period _period;

  _BarChartWidget(this._period, {Key? key}) : super(key: key) {
    _setSeries();
  }

  void _setSeries() {
    List<DayData> dayDataTable = TableCalculator.obtainData(_period);

    List<_Bar> projectionData = [];
    List<_Bar> burndownData = [];
    List<_Bar> remainingData = [];

    for (int i = 0; i < dayDataTable.length; i++) {
      projectionData.add(_Bar(i.toString(), dayDataTable[i].projection));
      burndownData.add(_Bar(i.toString(), dayDataTable[i].burndown));
      remainingData.add(_Bar(i.toString(), dayDataTable[i].remaining));
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
    return ExtraPadding(
      child: charts.OrdinalComboChart(
        _seriesList,
        animate: _animate,
        behaviors: [charts.SeriesLegend()],
        defaultRenderer: charts.BarRendererConfig(groupingType: charts.BarGroupingType.grouped),
      ),
    );
  }
}

class _Bar {
  final String label;
  final int? value;

  const _Bar(this.label, this.value);
}
