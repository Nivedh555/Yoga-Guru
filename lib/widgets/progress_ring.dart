import 'package:flutter/material.dart';

class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.value,
    required this.size,
    this.strokeWidth = 12,
    this.center,
  });

  final double value;
  final double size;
  final double strokeWidth;
  final Widget? center;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: value.clamp(0.0, 1.0),
              strokeWidth: strokeWidth,
              strokeCap: StrokeCap.round,
              backgroundColor: theme.colorScheme.outlineVariant,
            ),
          ),
          ?center,
        ],
      ),
    );
  }
}
