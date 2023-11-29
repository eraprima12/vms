import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

class PageSwitcherAnimations extends StatelessWidget {
  const PageSwitcherAnimations({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PageTransitionSwitcher(
      transitionBuilder: (
        Widget child,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
      ) {
        return SharedAxisTransition(
          fillColor: Colors.transparent,
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          transitionType: SharedAxisTransitionType.horizontal,
          child: child,
        );
      },
      duration: const Duration(seconds: 1),
      child: child,
    );
  }
}
