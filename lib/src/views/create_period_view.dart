import 'package:flutter/material.dart';
import 'package:kakeibo_ui/src/controllers/create_period_controller.dart';
import 'package:kakeibo_ui/src/decoration/loading_icon_widget.dart';
import 'package:kakeibo_ui/src/services/snackbar_service.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import '../decoration/extra_padding_widget.dart';

class CreatePeriodView extends StatelessWidget {
  static const routeName = '/create_period';
  const CreatePeriodView({Key? key}) : super(key: key);

  Widget form(BuildContext context) {
    CreatePeriodController ctrl = Provider.of<CreatePeriodController>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create a period'),
      ),
      body: Center(
        child: Form(
          key: ctrl.formKey,
          child: ExtraPadding(
            child: Column(
              children: [
                TextFormField(
                  onChanged: ctrl.onNameChanged,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the name';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(labelText: 'Period name'),
                ),
                Expanded(
                  child: SfDateRangePicker(
                    onSelectionChanged: ctrl.onSelectionChanged,
                    selectionMode: DateRangePickerSelectionMode.extendableRange,
                    view: DateRangePickerView.year,
                    initialSelectedRange:
                        PickerDateRange(ctrl.selectedStartDate, ctrl.selectedEndDate),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: ctrl.loading
                      ? null
                      : () async {
                          if (await ctrl.executeCreatePeriod()) {
                            SnackbarService.simpleSnackbar(context, "Created");
                            Navigator.of(context).pop(true);
                          }
                        },
                  icon: const Icon(Icons.add),
                  label: const Text("Create"),
                ),
                ctrl.loading ? const LoadingIcon() : Container()
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CreatePeriodController(),
      builder: (context, _) => form(context),
    );
  }
}
