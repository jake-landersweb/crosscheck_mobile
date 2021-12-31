import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class NoneFound extends StatelessWidget {
  const NoneFound(
    this.message, {
    Key? key,
    this.color = Colors.blue,
  }) : super(key: key);
  final String message;
  final Color color;

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
              "assets/svg/not_found.svg",
              semanticsLabel: 'Not found SVG',
              color: color,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            message,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 24),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
