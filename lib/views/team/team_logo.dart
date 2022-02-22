import 'package:flutter/material.dart';
import '../../custom_views/root.dart' as cv;

class TeamLogo extends StatefulWidget {
  const TeamLogo({
    Key? key,
    required this.url,
    this.size,
    this.color,
  }) : super(key: key);
  final String url;
  final double? size;
  final Color? color;

  @override
  _TeamLogoState createState() => _TeamLogoState();
}

class _TeamLogoState extends State<TeamLogo> {
  @override
  Widget build(BuildContext context) {
    if (widget.url != "") {
      return Image.network(
        widget.url,
        width: widget.size,
        height: widget.size,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            "assets/launch/x.png",
            color: widget.color,
            width: widget.size,
            height: widget.size,
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }
          return SizedBox(
            width: widget.size,
            height: widget.size,
            child: const cv.LoadingIndicator(),
          );
        },
      );
    } else {
      return Image.asset(
        "assets/launch/x.png",
        color: widget.color,
        width: widget.size,
        height: widget.size,
      );
    }
  }
}
