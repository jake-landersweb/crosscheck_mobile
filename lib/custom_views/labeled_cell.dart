import 'package:crosscheck_sports/client/root.dart';
import 'package:crosscheck_sports/data/indicator_item.dart';
import 'package:flutter/material.dart';
import 'package:crosscheck_sports/custom_views/core/root.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class LabeledCell extends StatelessWidget {
  const LabeledCell({
    Key? key,
    required this.label,
    required this.value,
    this.height = 50,
    this.textColor,
    this.clickable = false,
    this.onValueClick,
  }) : super(key: key);
  final String label;
  final String value;
  final double height;
  final Color? textColor;
  final bool clickable;
  final Function(String)? onValueClick;

  @override
  Widget build(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);
    return Row(
      children: [
        if (clickable)
          Expanded(
            child: BasicButton(
              onTap: () {
                if (onValueClick != null) {
                  onValueClick!(value);
                } else {
                  // copy to clipboard
                  Clipboard.setData(ClipboardData(text: value));
                  dmodel.addIndicator(
                    IndicatorItem.success("Successfully copied to clipboard."),
                  );
                }
              },
              child: Row(
                children: [
                  _value(context, dmodel),
                ],
              ),
            ),
          )
        else
          _value(context, dmodel),
        SizedBox(height: height),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color:
                (textColor == null ? ViewColors.textColor(context) : textColor!)
                    .withOpacity(0.5),
          ),
        ),
      ],
    );
  }

  Widget _value(BuildContext context, DataModel dmodel) {
    return Expanded(
      child: clickable
          ? Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: clickable ? dmodel.color : textColor,
                decoration: clickable ? TextDecoration.underline : null,
              ),
            )
          : SelectableText(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: clickable ? dmodel.color : textColor,
                decoration: clickable ? TextDecoration.underline : null,
              ),
            ),
    );
  }
}
