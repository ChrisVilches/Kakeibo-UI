import 'package:flutter/material.dart';
import 'package:kakeibo_ui/src/decoration/card_with_float_right_item_widget.dart';
import 'package:kakeibo_ui/src/decoration/date_util.dart';
import 'package:kakeibo_ui/src/decoration/format_util.dart';
import 'package:kakeibo_ui/src/models/day_data.dart';
import 'package:kakeibo_ui/src/models/period.dart';
import 'package:kakeibo_ui/src/widgets/misc/projection_widget.dart';
import 'package:kakeibo_ui/src/models/day.dart';
import 'package:kakeibo_ui/src/widgets/misc/memo_widget.dart';
import 'package:kakeibo_ui/src/widgets/misc/signed_amount_widget.dart';
import 'package:kakeibo_ui/src/widgets/scaffolds/day_detail_scaffold.dart';
import 'package:provider/provider.dart';

class DayListItemWidget extends StatelessWidget {
  final Function dayDetailModalClosedCallback;

  const DayListItemWidget({Key? key, required this.dayDetailModalClosedCallback}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DayData dayData = Provider.of<DayData>(context);
    Day day = dayData.day;

    var icon = Icon(Icons.check_rounded,
        color: day.budget == null ? Colors.grey : Colors.green, size: 20.0);

    List<Widget> columnChildren = [];
    int totalExpense = day.totalExpense();

    if (day.budget == null) {
      columnChildren.add(ProjectionWidget(dayData.projection));
    } else {
      columnChildren.add(Text(FormatUtil.formatNumberCurrency(day.budget),
          style: const TextStyle(fontWeight: FontWeight.bold)));
    }

    if (dayData.diff != null) {
      columnChildren.add(const SizedBox(height: 5));
      columnChildren.add(SignedAmountWidget(dayData.diff));
    }

    if (totalExpense > 0) {
      columnChildren.add(const SizedBox(height: 5));
      columnChildren.add(
        Row(
          children: [
            const Icon(Icons.receipt_long, size: 15, color: Colors.grey),
            const SizedBox(width: 5),
            Text('-' + FormatUtil.formatNumberCurrency(day.totalExpense()),
                style: const TextStyle(color: Colors.grey))
          ],
        ),
      );
    }

    Widget card = CardWithFloatRightItemWidget(
        icon: icon,
        label: Column(
          children: [
            Text(DateUtil.formatDate(day.dayDate)),
            const SizedBox(height: 5),
            day.memo.isEmpty ? Container() : MemoWidget(day.memo),
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        rightWidget: Column(
          children: columnChildren,
          crossAxisAlignment: CrossAxisAlignment.end,
        ));

    return InkWell(
      onTap: () async {
        Navigator.of(context)
            .push(
              MaterialPageRoute(
                builder: (_) {
                  return MultiProvider(
                    providers: [
                      Provider<Period>.value(value: context.read<Period>()),
                      Provider<DayData>.value(value: context.read<DayData>()),
                    ],
                    builder: (_, __) => const DayDetailScaffold(),
                  );
                },
                fullscreenDialog: true,
              ),
            )
            .then((_) => dayDetailModalClosedCallback);
      },
      child: card,
    );
  }
}
