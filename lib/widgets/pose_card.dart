import 'package:flutter/material.dart';

import '../models/yoga_pose.dart';
import 'surface_card.dart';

class DifficultyPill extends StatelessWidget {
  const DifficultyPill({
    super.key,
    required this.difficulty,
    this.compact = false,
  });

  final PoseDifficulty difficulty;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color color = switch (difficulty) {
      PoseDifficulty.beginner => const Color(0xFF4E7D57),
      PoseDifficulty.intermediate => const Color(0xFFA3713A),
      PoseDifficulty.advanced => const Color(0xFF9C4A2F),
    };
    final Color background = theme.brightness == Brightness.dark
        ? color.withValues(alpha: 0.24)
        : color.withValues(alpha: 0.12);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        difficulty.label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class PoseThumbnail extends StatelessWidget {
  const PoseThumbnail({
    super.key,
    required this.pose,
    this.size = 64,
    this.radius = 16,
    this.padding = 6,
  });

  final YogaPose pose;
  final double size;
  final double radius;
  final double padding;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Image.asset(
        pose.imageAsset,
        fit: BoxFit.contain,
        errorBuilder:
            (BuildContext context, Object error, StackTrace? stackTrace) =>
                Icon(
                  Icons.self_improvement,
                  size: size * 0.5,
                  color: theme.colorScheme.onSecondaryContainer,
                ),
      ),
    );
  }
}

class PoseCard extends StatelessWidget {
  const PoseCard({super.key, required this.pose, this.onTap});

  final YogaPose pose;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return SurfaceCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              color: theme.colorScheme.secondaryContainer.withValues(
                alpha: theme.brightness == Brightness.dark ? 0.35 : 0.55,
              ),
              child: Image.asset(
                pose.imageAsset,
                fit: BoxFit.contain,
                errorBuilder:
                    (
                      BuildContext context,
                      Object error,
                      StackTrace? stackTrace,
                    ) => Icon(
                      Icons.self_improvement,
                      size: 44,
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  pose.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  pose.sanskritName,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: <Widget>[
                    Flexible(
                      child: DifficultyPill(
                        difficulty: pose.difficulty,
                        compact: true,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Spacer(),
                    Flexible(
                      child: Text(
                        '${pose.holdSeconds}s',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PoseTile extends StatelessWidget {
  const PoseTile({super.key, required this.pose, this.onTap});

  final YogaPose pose;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return SurfaceCard(
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: <Widget>[
          PoseThumbnail(pose: pose, size: 62),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  pose.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${pose.sanskritName} • ${pose.focus}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: <Widget>[
                    DifficultyPill(difficulty: pose.difficulty, compact: true),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.schedule,
                      size: 13,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '${pose.holdSeconds}s',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: theme.colorScheme.onSurfaceVariant),
        ],
      ),
    );
  }
}
