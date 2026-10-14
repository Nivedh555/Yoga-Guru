import 'package:flutter/material.dart';

import '../models/yoga_session.dart';
import 'pose_card.dart';
import 'surface_card.dart';

class SessionCard extends StatelessWidget {
  const SessionCard({
    super.key,
    required this.session,
    this.onTap,
    this.width = 240,
  });

  final YogaSession session;
  final VoidCallback? onTap;
  final double width;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return SizedBox(
      width: width,
      child: SurfaceCard(
        onTap: onTap,
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 126,
              width: double.infinity,
              child: Container(
                padding: const EdgeInsets.all(12),
                color: theme.colorScheme.secondaryContainer.withValues(
                  alpha: theme.brightness == Brightness.dark ? 0.35 : 0.55,
                ),
                child: Image.asset(
                  session.cover.imageAsset,
                  fit: BoxFit.contain,
                  errorBuilder:
                      (
                        BuildContext context,
                        Object error,
                        StackTrace? stackTrace,
                      ) => Icon(
                        Icons.self_improvement,
                        size: 48,
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      session.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Flexible(
                      child: Text(
                        session.subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: <Widget>[
                        Flexible(
                          child: DifficultyPill(
                            difficulty: session.difficulty,
                            compact: true,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Spacer(),
                        Icon(
                          Icons.schedule,
                          size: 14,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            '${session.minutes} min',
                            style: theme.textTheme.labelMedium?.copyWith(
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
            ),
          ],
        ),
      ),
    );
  }
}
