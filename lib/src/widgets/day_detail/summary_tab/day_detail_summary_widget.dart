import 'package:flutter/material.dart';
import 'package:kakeibo_ui/src/models/navigation_store.dart';
import 'package:kakeibo_ui/src/decoration/card_with_float_right_item_widget.dart';
import 'package:kakeibo_ui/src/models/day_data.dart';
import 'package:kakeibo_ui/src/widgets/misc/projection_widget.dart';
import 'package:kakeibo_ui/src/widgets/misc/remaining_budget_widget.dart';
import 'package:kakeibo_ui/src/models/day.dart';
import 'package:kakeibo_ui/src/widgets/misc/burndown_widget.dart';
import 'package:kakeibo_ui/src/widgets/misc/signed_amount_widget.dart';
import 'package:provider/provider.dart';

class DayDetailSummaryWidget extends StatelessWidget {
  const DayDetailSummaryWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Day day = Provider.of<NavigationStore>(context).currentDay!;
    DayData dayData = Provider.of<NavigationStore>(context).dayDataForDay(day);

    var remainingCard = CardWithFloatRightItemWidget(
      icon: const Icon(Icons.attach_money_rounded),
      label: const Text("Remaining cash"),
      rightWidget: RemainingBudgetWidget(dayData.remaining),
    );

    var burndownCard = CardWithFloatRightItemWidget(
      icon: const Icon(Icons.trending_down),
      label: const Text("Burndown"),
      rightWidget: BurndownWidget(dayData.burndown),
    );

    var projectionCard = CardWithFloatRightItemWidget(
      icon: const Icon(Icons.waterfall_chart),
      label: const Text("Projection"),
      rightWidget: ProjectionWidget(dayData.projection),
    );

    var diffCard = CardWithFloatRightItemWidget(
      icon: const Icon(Icons.exposure_outlined),
      label: const Text("Difference"),
      rightWidget: SignedAmountWidget(dayData.diff),
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
