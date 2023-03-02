import 'package:crosscheck_sports/extras/root.dart';
import 'package:flutter/material.dart';
import 'package:crosscheck_sports/client/root.dart';
import 'package:crosscheck_sports/main.dart';
import 'package:provider/provider.dart';
import '../../custom_views/root.dart' as cv;
import '../components/root.dart' as comp;

class Suggestions extends StatefulWidget {
  const Suggestions({
    Key? key,
    required this.email,
  }) : super(key: key);
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
    return cv.Sheet(
      title: "Send Feedback",
      color: dmodel.color,
      child: Column(
        children: [
          const Text(
            "We are still actively working on features, so any feedback received is highly appreciated.",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          cv.ListView<Widget>(
            childPadding: const EdgeInsets.symmetric(horizontal: 16),
            horizontalPadding: 0,
            backgroundColor: CustomColors.textColor(context).withOpacity(0.1),
            children: [
              cv.TextField2(
                labelText: "Feedback",
                isLabeled: false,
                showBackground: false,
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
                ? comp.ActionButton(
                    color: dmodel.color,
                    title: _buttonText(),
                    onTap: () => _action(context, dmodel))
                : comp.DestructionButton(
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
