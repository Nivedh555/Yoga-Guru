import 'package:flutter/material.dart';

import '../models/session_record.dart';
import '../models/yoga_pose.dart';
import '../utils/formatters.dart';
import '../utils/page_transitions.dart';
import '../widgets/stat_tile.dart';
import 'session_screen.dart';

class SessionCompleteScreen extends StatelessWidget {
  const SessionCompleteScreen({
    super.key,
    required this.record,
    required this.poses,
    required this.completedFully,
  });

  final SessionRecord record;
  final List<YogaPose> poses;
  final bool completedFully;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Session summary')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: <Widget>[
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    size: 52,
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  completedFully ? 'Session complete' : 'Session saved',
                  style: theme.textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  completedFully
                      ? 'You finished ${record.title}. Well done, keep up the consistency.'
                      : 'You ended ${record.title} a little early. The time you practiced has been saved.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: StatTile(
                        value: formatDurationLabel(record.seconds),
                        label: 'Time practiced',
                        icon: Icons.timer_outlined,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatTile(
                        value: '${record.poseCount}',
                        label: record.poseCount == 1 ? 'Pose' : 'Poses',
                        icon: Icons.self_improvement,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        FadeScaleRoute<void>(
                          page: SessionScreen(
                            title: record.title,
                            poses: poses,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.replay_rounded),
                    label: const Text('Practice again'),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Done'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
