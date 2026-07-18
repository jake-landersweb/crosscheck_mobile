import 'package:crosscheck_sports/extras/root.dart';
import 'package:flutter/material.dart';
import 'package:crosscheck_sports/client/root.dart';
import 'package:provider/provider.dart';
import 'package:crosscheck_sports/components/layer/header_bar.dart';
import 'package:crosscheck_sports/components/layer/action_button.dart';
import 'package:crosscheck_sports/components/layer/wide_button.dart';
import 'package:crosscheck_sports/components/layer/field.dart';
import 'package:crosscheck_sports/components/core/cell_list.dart';

class Suggestions extends StatefulWidget {
  const Suggestions({
    super.key,
    required this.email,
  });
  final String email;

  @override
  State<Suggestions> createState() => _SuggestionsState();
}

class _SuggestionsState extends State<Suggestions> {
  String _feedback = "";
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return HeaderBar.sheet(
      title: "Send Feedback",
      trailing: XCActionButton.cancel(
        onTap: () => Navigator.of(context).pop(),
      ),
      child: Column(
        children: [
          const Text(
            "We are still actively working on features, so any feedback received is highly appreciated.",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          XCCellList<Widget>(
            childPadding: const EdgeInsets.symmetric(horizontal: 16),
            horizontalPadding: 0,
            backgroundColor: CustomColors.textColor(context).withOpacity(0.1),
            children: [
              XCField(
              labelText: "Feedback",
              isLabeled: false,
              value: _feedback,
              onChanged: (value) {
                  setState(() {
                    _feedback = value;
                  });
                },
            ),
            ],
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _buttonText() == "Send"
                ? XCWideButton.primary(
                    color: dmodel.color,
                    title: _buttonText(),
                    onTap: () => _action(context, dmodel))
                : XCWideButton.destructive(
                    title: _buttonText(),
                    onTap: () {},
                  ),
          ),
        ],
      ),
    );
  }

  String _buttonText() {
    if (_feedback.isEmpty) {
      return "Cannot be Empty";
    } else {
      return "Send";
    }
  }

  Future<void> _action(BuildContext context, DataModel dmodel) async {
    if (!_isLoading && _buttonText() == "Send") {
      setState(() {
        _isLoading = true;
      });
      // send email
      await dmodel.sendFeedback(widget.email, {"message": _feedback}, () {
        Navigator.of(context).pop();
      });
      setState(() {
        _isLoading = true;
      });
    }
  }
}
