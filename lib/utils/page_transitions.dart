import 'package:flutter/material.dart';

class FadeScaleRoute<T> extends PageRouteBuilder<T> {
  FadeScaleRoute({required this.page})
    : super(
        transitionDuration: const Duration(milliseconds: 280),
        reverseTransitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (
          BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
        ) => page,
        transitionsBuilder:
            (
              BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
              Widget child,
            ) {
              final CurvedAnimation curved = CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              );
              return FadeTransition(
                opacity: curved,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.97, end: 1).animate(curved),
                  child: child,
                ),
              );
            },
      );

  final Widget page;
}
