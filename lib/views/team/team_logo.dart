import 'package:cached_network_image/cached_network_image.dart';
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
      return CachedNetworkImage(
        imageUrl: widget.url,
        cacheKey: widget.url,
        width: widget.size,
        fadeInDuration: const Duration(milliseconds: 100),
        fadeOutDuration: const Duration(milliseconds: 100),
        height: widget.size,
        errorWidget: (context, error, stackTrace) => _baseImage(context, false),
        placeholder: (context, _) => _baseImage(context, true),
      );
    } else {
      return _baseImage(context, false);
    }
  }

  Widget _baseImage(BuildContext context, bool isLoading) {
    var w = Image.asset(
      "assets/launch/x.png",
      color: widget.color,
      width: widget.size,
      height: widget.size,
    );
    if (isLoading) {
      return cv.LoadingWrapper(child: w);
    } else {
      return w;
    }
  }
}
