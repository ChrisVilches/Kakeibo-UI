import 'package:flutter/material.dart';

class MemoWidget extends StatelessWidget {
  final String _text;

  const MemoWidget(this._text, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.textsms_outlined, size: 15, color: Colors.grey),
        const SizedBox(width: 5),
        Text(_text,
            style: const TextStyle(color: Colors.grey),
            overflow: TextOverflow.ellipsis)
      ],
    );
  }
}
