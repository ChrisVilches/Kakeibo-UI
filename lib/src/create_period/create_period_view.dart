import 'package:flutter/material.dart';
import 'package:kakeibo_ui/src/decoration/loading_icon_widget.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import '../decoration/extra_padding_widget.dart';
import '../services/graphql_services.dart';
import '../services/locator.dart';

// TODO: Also divide in service + controllers? (like the settings view)

class CreatePeriodView extends StatefulWidget {
  static const routeName = '/create_period';
  const CreatePeriodView({Key? key}) : super(key: key);

  @override
  CreatePeriodState createState() => CreatePeriodState();
}

class CreatePeriodState extends State<CreatePeriodView> {
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  String _selectedName = "";
  DateTime _selectedStartDate = DateTime.now();
  DateTime _selectedEndDate = DateTime.now().add(const Duration(days: 7));

  void _executeCreatePeriod() async {
    setState(() {
      _loading = true;
    });

    await serviceLocator
        .get<GraphQLServices>()
        .createPeriod(_selectedName, _selectedStartDate, _selectedEndDate);

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Created'),
    ));

    Navigator.of(context).pop(true);
  }

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    setState(() {
      _selectedStartDate = args.value.startDate;
      _selectedEndDate = args.value.endDate;
    });
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _executeCreatePeriod();
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: "Expanded" fixes the "incorrect parent, etc" error, but looks too big.
    Widget dateRangePicker = Expanded(
        child: SfDateRangePicker(
            onSelectionChanged: _onSelectionChanged,
            selectionMode: DateRangePickerSelectionMode.extendableRange,
            view: DateRangePickerView.year,
            initialSelectedRange:
                PickerDateRange(_selectedStartDate, _selectedEndDate)));

    Widget nameInput = TextFormField(
        onChanged: (text) => {
              setState(() {
                _selectedName = text;
              })
            },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter the name';
          }
          return null;
        },
        decoration: const InputDecoration(labelText: 'Period name'));

    Widget submitButton = ElevatedButton.icon(
      onPressed: _loading ? null : _submitForm,
      icon: const Icon(Icons.add),
      label: const Text("Create"),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create a period'),
      ),
      body: Center(
        child: Form(
          key: _formKey,
          child: ExtraPadding(
            child: Column(
              children: [
                nameInput,
                dateRangePicker,
                submitButton,
                _loading ? const LoadingIcon() : Container()
              ],
            ),
          ),
        ),
      ),
    );
  }
}
