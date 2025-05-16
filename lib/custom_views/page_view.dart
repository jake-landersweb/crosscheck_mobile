import 'package:flutter/material.dart';

class SizingPageView extends StatelessWidget {
  final ScrollPhysics? physics;
  final PageController controller;
  final List<Widget> children;

  const SizingPageView({
    super.key,
    this.physics,
    required this.controller,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    Widget transform(Widget input) {
      return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: input,
      );
    }

    return SingleChildScrollView(
      physics: physics ?? const PageScrollPhysics(),
      controller: controller,
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children.map(transform).toList(),
      ),
    );
  }
}
