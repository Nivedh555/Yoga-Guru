import 'package:flutter/material.dart';

import 'surface_card.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return SurfaceCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: <Widget>[
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: theme.colorScheme.secondaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 30,
              color: theme.colorScheme.onSecondaryContainer,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          if (actionLabel != null && onAction != null) ...<Widget>[
            const SizedBox(height: 18),
            FilledButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}
