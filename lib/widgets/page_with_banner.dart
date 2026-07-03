import 'package:flutter/material.dart';

class PageWithBanner extends StatelessWidget {
  final Widget child;

  const PageWithBanner({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: child),
       // const BannerAdWidget(),
      ],
    );
  }
}
