import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kakeibo_ui/src/decoration/form_validators.dart';

class DigitsOnlyInputWidget extends StatelessWidget {
  final String _label;
  final String? initialValue;
  final bool required;
  final void Function(String?) onChanged;
  final String hintText;

  const DigitsOnlyInputWidget(
    this._label, {
    Key? key,
    this.required = true,
    required this.onChanged,
    this.initialValue,
    this.hintText = '',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onChanged: onChanged,
      initialValue: initialValue,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: required ? FormValidators.amountValidator : null,
      decoration: InputDecoration(labelText: _label, hintText: hintText),
    );
  }
}
