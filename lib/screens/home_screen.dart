import 'package:flutter/material.dart';

import '../data/pose_repository.dart';
import '../data/session_plans.dart';
import '../models/yoga_pose.dart';
import '../models/yoga_session.dart';
import '../services/app_scope.dart';
import '../services/app_state.dart';
import '../utils/formatters.dart';
import '../utils/page_transitions.dart';
import '../widgets/pose_card.dart';
import '../widgets/section_header.dart';
import '../widgets/session_card.dart';
import '../widgets/surface_card.dart';
import 'pose_detail_screen.dart';
import 'session_screen.dart';

const List<String> _popularPoseIds = <String>[
  'tadasana',
  'vrikshasana',
  'trikonasana',
  'bhujangasana',
  'virbhadrasana',
  'sukhasana',
];

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onOpenExplore});

  final void Function({PoseDifficulty? difficulty}) onOpenExplore;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppState state = AppScope.of(context);
    final List<YogaSession> featured = SessionPlans.featured;
    final YogaSession heroSession = featured.first;
    final List<YogaPose> popular = _popularPoseIds
        .map((String id) => PoseRepository.byId(id))
        .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    greetingForHour(DateTime.now().hour),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    state.displayName,
                    style: theme.textTheme.headlineSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _TodayChip(
              minutes: state.todayMinutes,
              goalMinutes: state.dailyGoalMinutes,
            ),
          ],
        ),
        const SizedBox(height: 20),
        _HeroCard(
          session: heroSession,
          onStart: () => _openSession(context, heroSession),
        ),
        const SizedBox(height: 26),
        const SectionHeader(title: 'Featured sessions'),
        const SizedBox(height: 12),
        SizedBox(
          height: 258,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: featured.length,
            separatorBuilder: (BuildContext context, int index) =>
                const SizedBox(width: 14),
            itemBuilder: (BuildContext context, int index) {
              final YogaSession session = featured[index];
              return SessionCard(
                session: session,
                onTap: () => _openSession(context, session),
              );
            },
          ),
        ),
        const SizedBox(height: 26),
        const SectionHeader(title: 'Choose your level'),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            Expanded(
              child: _LevelCard(
                difficulty: PoseDifficulty.beginner,
                onTap: () => onOpenExplore(difficulty: PoseDifficulty.beginner),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _LevelCard(
                difficulty: PoseDifficulty.intermediate,
                onTap: () =>
                    onOpenExplore(difficulty: PoseDifficulty.intermediate),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _LevelCard(
                difficulty: PoseDifficulty.advanced,
                onTap: () => onOpenExplore(difficulty: PoseDifficulty.advanced),
              ),
            ),
          ],
        ),
        const SizedBox(height: 26),
        SectionHeader(
          title: 'Popular poses',
          actionLabel: 'See all',
          onAction: () => onOpenExplore(),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 188,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: popular.length,
            separatorBuilder: (BuildContext context, int index) =>
                const SizedBox(width: 12),
            itemBuilder: (BuildContext context, int index) {
              final YogaPose pose = popular[index];
              return SizedBox(
                width: 150,
                child: PoseCard(
                  pose: pose,
                  onTap: () {
                    Navigator.of(context).push(
                      FadeScaleRoute<void>(page: PoseDetailScreen(pose: pose)),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _openSession(BuildContext context, YogaSession session) {
    Navigator.of(context).push(
      FadeScaleRoute<void>(
        page: SessionScreen(title: session.title, poses: session.poses),
      ),
    );
  }
}

class _TodayChip extends StatelessWidget {
  const _TodayChip({required this.minutes, required this.goalMinutes});

  final int minutes;
  final int goalMinutes;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool reached = minutes >= goalMinutes;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            reached ? Icons.check_circle : Icons.timelapse_rounded,
            size: 15,
            color: theme.colorScheme.onSecondaryContainer,
          ),
          const SizedBox(width: 6),
          Text(
            '$minutes / $goalMinutes min',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.session, required this.onStart});

  final YogaSession session;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color onContainer = theme.colorScheme.onPrimaryContainer;

    return SurfaceCard(
      color: theme.colorScheme.primaryContainer,
      showBorder: false,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Today's practice",
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: onContainer.withValues(alpha: 0.75),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      session.title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: onContainer,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      session.subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: onContainer.withValues(alpha: 0.85),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${session.poses.length} poses • ${session.minutes} min • '
                      '${session.difficulty.label}',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: onContainer.withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 96,
                height: 96,
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
                        size: 56,
                        color: onContainer,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
              onPressed: onStart,
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Start session'),
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  const _LevelCard({required this.difficulty, required this.onTap});

  final PoseDifficulty difficulty;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final int count = PoseRepository.byDifficulty(difficulty).length;
    final Color accent = switch (difficulty) {
      PoseDifficulty.beginner => const Color(0xFF4E7D57),
      PoseDifficulty.intermediate => const Color(0xFFA3713A),
      PoseDifficulty.advanced => const Color(0xFF9C4A2F),
    };

    return SurfaceCard(
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.self_improvement, size: 20, color: accent),
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              difficulty.label,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$count poses',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
