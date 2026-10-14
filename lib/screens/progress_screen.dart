import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/session_plans.dart';
import '../models/session_record.dart';
import '../models/yoga_session.dart';
import '../services/app_scope.dart';
import '../services/app_state.dart';
import '../utils/formatters.dart';
import '../utils/page_transitions.dart';
import '../widgets/empty_state.dart';
import '../widgets/progress_ring.dart';
import '../widgets/section_header.dart';
import '../widgets/stat_tile.dart';
import '../widgets/surface_card.dart';
import 'session_screen.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppState state = AppScope.of(context);
    final List<SessionRecord> recent = state.recentRecords;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      children: <Widget>[
        Text('Your progress', style: theme.textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text(
          'Consistent practice, visible results.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: <Widget>[
            Expanded(
              child: StatTile(
                value: '${state.totalSessions}',
                label: state.totalSessions == 1 ? 'Session' : 'Sessions',
                icon: Icons.self_improvement,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: StatTile(
                value: '${state.totalMinutes}',
                label: 'Minutes',
                icon: Icons.timer_outlined,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: StatTile(
                value: '${state.streakDays}',
                label: 'Streak',
                icon: Icons.local_fire_department_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _TodayGoalCard(state: state),
        const SizedBox(height: 24),
        const SectionHeader(title: 'Last 7 days'),
        const SizedBox(height: 12),
        _WeekChart(state: state),
        const SizedBox(height: 24),
        const SectionHeader(title: 'Recent sessions'),
        const SizedBox(height: 12),
        if (recent.isEmpty)
          EmptyState(
            icon: Icons.history,
            title: 'No sessions yet',
            message:
                'Finish a guided session and your history will appear here.',
            actionLabel: 'Start a session',
            onAction: () {
              final YogaSession session = SessionPlans.byId(
                'morning-energiser',
              );
              Navigator.of(context).push(
                FadeScaleRoute<void>(
                  page: SessionScreen(
                    title: session.title,
                    poses: session.poses,
                  ),
                ),
              );
            },
          )
        else
          SurfaceCard(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              children: <Widget>[
                for (int i = 0; i < recent.length && i < 8; i++) ...<Widget>[
                  if (i > 0) const Divider(height: 1, indent: 68),
                  ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        size: 20,
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                    ),
                    title: Text(
                      recent[i].title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      '${formatDayLabel(recent[i].completedAt)} • '
                      '${formatTimeOfDay(recent[i].completedAt)} • '
                      '${recent[i].poseCount} poses',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Text(
                      formatDurationLabel(recent[i].seconds),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _TodayGoalCard extends StatelessWidget {
  const _TodayGoalCard({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final int remaining = (state.dailyGoalMinutes - state.todayMinutes).clamp(
      0,
      999,
    );
    final bool reached = state.todaySeconds >= state.dailyGoalMinutes * 60;

    return SurfaceCard(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: <Widget>[
          ProgressRing(
            value: state.todayGoalProgress,
            size: 92,
            strokeWidth: 10,
            center: Text(
              '${(state.todayGoalProgress * 100).round()}%',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "Today's practice",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${state.todayMinutes} of ${state.dailyGoalMinutes} minutes',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  reached
                      ? 'Daily goal complete. Well done!'
                      : '$remaining minutes to reach your goal',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WeekChart extends StatelessWidget {
  const _WeekChart({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<DateTime> days = state.lastSevenDays;
    final List<int> seconds = state.lastSevenDaysSeconds;
    final int maxSeconds = math.max(
      seconds.fold<int>(1, (int a, int b) => math.max(a, b)),
      1,
    );
    final int weekTotalMinutes =
        (seconds.fold<int>(0, (int a, int b) => a + b) / 60).round();

    return SurfaceCard(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 132,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                for (int i = 0; i < 7; i++)
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          seconds[i] == 0 ? '' : '${(seconds[i] / 60).round()}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: seconds[i] == 0
                              ? 6
                              : (seconds[i] / maxSeconds * 92)
                                    .clamp(10, 92)
                                    .toDouble(),
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                            color: _isToday(days[i])
                                ? theme.colorScheme.primary
                                : seconds[i] == 0
                                ? theme.colorScheme.outlineVariant
                                : theme.colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 6),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            _isToday(days[i]) ? 'Today' : weekdayShort(days[i]),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: _isToday(days[i])
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurfaceVariant,
                              fontWeight: _isToday(days[i])
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$weekTotalMinutes minutes this week',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  bool _isToday(DateTime day) {
    final DateTime now = DateTime.now();
    return day.year == now.year && day.month == now.month && day.day == now.day;
  }
}
