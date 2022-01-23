import 'package:flutter/material.dart';
import 'package:kakeibo_ui/src/models/navigation_store.dart';
import 'package:kakeibo_ui/src/decoration/date_util.dart';
import 'package:kakeibo_ui/src/models/period.dart';
import 'package:kakeibo_ui/src/views/period_details_view.dart';
import 'package:provider/provider.dart';

class PeriodsListMainWidget extends StatelessWidget {
  final List<Period> periods;
  final Function onBackFromDetailView;

  const PeriodsListMainWidget({Key? key, required this.periods, required this.onBackFromDetailView})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
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
          onTap: () async {
            Provider.of<NavigationStore>(context, listen: false).loadPeriod(period.id!);

            await Navigator.of(context).pushNamed(PeriodDetailsView.routeName);
            onBackFromDetailView();
          },
        );
      },
    );
  }
}
