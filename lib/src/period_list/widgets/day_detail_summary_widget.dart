import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kakeibo_ui/src/decoration/card_with_float_right_item_widget.dart';
import 'package:kakeibo_ui/src/decoration/padding_bottom_widget.dart';
import 'package:kakeibo_ui/src/models/day.dart';
import 'package:kakeibo_ui/src/period_list/widgets/projection_widget.dart';
import 'package:kakeibo_ui/src/period_list/widgets/remaining_budget_widget.dart';
import 'package:kakeibo_ui/src/period_list/widgets/signed_amount_widget.dart';

import 'burndown_widget.dart';

class DayDetailSummaryWidget extends StatelessWidget {
  final Day day;
  final int? remaining;
  final int burndown;
  final int? projection;
  final int? diff;

  const DayDetailSummaryWidget(
      {Key? key,
      required this.day,
      required this.remaining,
      required this.burndown,
      required this.projection,
      required this.diff})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var remainingCard = CardWithFloatRightItemWidget(
      icon: const Icon(Icons.attach_money_rounded),
      label: const Text("Remaining cash"),
      rightWidget: RemainingBudgetWidget(remaining),
    );

    var burndownCard = CardWithFloatRightItemWidget(
      icon: const Icon(Icons.trending_down),
      label: const Text("Burndown"),
      rightWidget: BurndownWidget(burndown),
    );

    var projectionCard = CardWithFloatRightItemWidget(
      icon: const Icon(Icons.waterfall_chart),
      label: const Text("Projection"),
      rightWidget: ProjectionWidget(projection),
    );

    var diffCard = CardWithFloatRightItemWidget(
      icon: const Icon(Icons.exposure_outlined),
      label: const Text("Difference"),
      rightWidget: SignedAmountWidget(diff),
    );

    return Column(
      children: [
        day.budget == null ? Container() : remainingCard,
        burndownCard,
        day.budget == null ? projectionCard : Container(),
        diffCard,
      ],
    );
  }
}
