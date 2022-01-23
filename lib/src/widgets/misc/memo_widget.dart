import 'package:flutter/material.dart';
import 'package:kakeibo_ui/src/decoration/format_util.dart';

class MemoWidget extends StatelessWidget {
  final String _text;
  late final String _shortText = FormatUtil.limitMultilineString(string: _text, maxLines: 3);

  MemoWidget(this._text, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
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
              _shortText,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }
}
