import 'package:flutter/material.dart';
import 'package:pnflutter/client/root.dart';
import 'package:pnflutter/main.dart';
import 'package:provider/provider.dart';
import '../../custom_views/root.dart' as cv;

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
            validator: (value) => null,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: cv.RoundedLabel(
              _buttonText(),
              textColor: Colors.white,
              color: _buttonText() == "Send"
                  ? dmodel.color
                  : Colors.red.withOpacity(0.5),
              isLoading: _isLoading,
              onTap: () => _action(context, dmodel),
            ),
          )
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
