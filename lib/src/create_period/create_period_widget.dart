import 'package:flutter/material.dart';
import 'package:kakeibo_ui/src/services/graphql_client.dart';
import 'package:kakeibo_ui/src/services/locator.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

Widget loadingIcon = const SpinKitFadingCircle(
  color: Colors.white,
  size: 50.0,
);

class CreatePeriodWidget extends StatefulWidget {
  static const routeName = '/create_period';
  const CreatePeriodWidget({Key? key}) : super(key: key);

  @override
  CreatePeriodState createState() => CreatePeriodState();
}

class CreatePeriodState extends State<CreatePeriodWidget> {
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  String _selectedName = "";
  DateTime _selectedStartDate = DateTime.now();
  DateTime _selectedEndDate = DateTime.now().add(const Duration(days: 7));

  // TODO: Use it so that the name is created automatically.
  String _defaultName() {
    return "$_selectedStartDate - $_selectedEndDate";
  }

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

    Navigator.pop(context);
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
      //ScaffoldMessenger.of(context).showSnackBar(
      //  const SnackBar(content: Text('Creating...')),
      //);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget dateRangePicker = Positioned(
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

    Widget submitButton = ElevatedButton(
      onPressed: _loading ? null : _submitForm,
      child: const Text('Create'),
    );

    return Scaffold(
        appBar: AppBar(
          title: const Text('Create a period'),
        ),
        body: Center(
            child: Form(
                key: _formKey,
                child: Column(children: [
                  nameInput,
                  dateRangePicker,
                  submitButton,
                  _loading ? loadingIcon : Text('')
                ]))));
  }
}
