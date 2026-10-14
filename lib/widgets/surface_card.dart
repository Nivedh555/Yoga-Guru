import 'package:flutter/material.dart';

class SurfaceCard extends StatelessWidget {
  const SurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.color,
    this.borderRadius = 22,
    this.showBorder = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;
  final double borderRadius;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final BorderRadius radius = BorderRadius.circular(borderRadius);

    return Material(
      color: color ?? theme.colorScheme.surface,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: radius,
            border: showBorder
                ? Border.all(color: theme.colorScheme.outlineVariant)
                : null,
          ),
          child: child,
        ),
      ),
    );
  }
}
