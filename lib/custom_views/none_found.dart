import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class NoneFound extends StatelessWidget {
  const NoneFound(
    this.message, {
    Key? key,
    this.color = Colors.blue,
    this.asset,
    this.textColor,
  }) : super(key: key);
  final String message;
  final Color color;
  final String? asset;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 50),
          child: SizedBox(
            height: 300,
            width: 300,
            child: SvgPicture.asset(
              asset ?? "assets/svg/no_data.svg",
              semanticsLabel: 'Not found SVG',
              // color: color,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            message,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 24,
              color: textColor,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
