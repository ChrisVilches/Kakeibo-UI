import 'package:flutter/material.dart';

class MemoWidget extends StatelessWidget {
  final String _text;

  const MemoWidget(this._text, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      // TODO: What does this "min" do????
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        const SizedBox(
          width: 0,
          child: Icon(Icons.textsms_outlined, size: 15, color: Colors.grey),
        ),
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.only(left: 25),
            child: Text(
              _text,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }
}
