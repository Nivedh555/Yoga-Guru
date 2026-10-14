import 'package:flutter/material.dart';

import '../services/app_scope.dart';
import '../services/app_state.dart';
import '../widgets/section_header.dart';
import '../widgets/surface_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppState state = AppScope.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: <Widget>[
            const SectionHeader(title: 'Appearance'),
            const SizedBox(height: 10),
            SurfaceCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Theme',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Choose how Yoga Guru looks on this device.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<ThemeMode>(
                      style: SegmentedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      segments: const <ButtonSegment<ThemeMode>>[
                        ButtonSegment<ThemeMode>(
                          value: ThemeMode.system,
                          label: Text('System'),
                        ),
                        ButtonSegment<ThemeMode>(
                          value: ThemeMode.light,
                          label: Text('Light'),
                        ),
                        ButtonSegment<ThemeMode>(
                          value: ThemeMode.dark,
                          label: Text('Dark'),
                        ),
                      ],
                      selected: <ThemeMode>{state.themeMode},
                      onSelectionChanged: (Set<ThemeMode> selection) async {
                        final bool saved = await state.setThemeMode(
                          selection.first,
                        );
                        if (!context.mounted) {
                          return;
                        }
                        if (!saved) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Could not save the theme setting.',
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const SectionHeader(title: 'Practice'),
            const SizedBox(height: 10),
            SurfaceCard(
              padding: const EdgeInsets.all(16),
              child: _GoalSlider(
                initialMinutes: state.dailyGoalMinutes,
                onSave: (int minutes) async {
                  final bool saved = await state.setDailyGoalMinutes(minutes);
                  if (!context.mounted) {
                    return;
                  }
                  if (!saved) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Could not save the daily goal.'),
                      ),
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 22),
            const SectionHeader(title: 'Data'),
            const SizedBox(height: 10),
            SurfaceCard(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                leading: Icon(
                  Icons.delete_outline,
                  color: theme.colorScheme.error,
                ),
                title: const Text('Reset progress'),
                subtitle: const Text('Deletes all saved session history'),
                onTap: () => _confirmReset(context, state),
              ),
            ),
            const SizedBox(height: 22),
            const SectionHeader(title: 'About'),
            const SizedBox(height: 10),
            const SurfaceCard(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Yoga Guru'),
                  SizedBox(height: 4),
                  Text('Version 1.0.0 • Offline yoga instructor app'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context, AppState state) async {
    final bool confirm =
        await showDialog<bool>(
          context: context,
          builder: (BuildContext dialogContext) => AlertDialog(
            title: const Text('Reset progress?'),
            content: const Text(
              'This permanently deletes all your saved session history. '
              'This action cannot be undone.',
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(dialogContext).colorScheme.error,
                  foregroundColor: Theme.of(dialogContext).colorScheme.onError,
                ),
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('Reset'),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirm) {
      return;
    }
    if (!context.mounted) {
      return;
    }
    final bool cleared = await state.resetProgress();
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          cleared ? 'Progress cleared.' : 'Could not clear progress.',
        ),
      ),
    );
  }
}

class _GoalSlider extends StatefulWidget {
  const _GoalSlider({required this.initialMinutes, required this.onSave});

  final int initialMinutes;
  final Future<void> Function(int minutes) onSave;

  @override
  State<_GoalSlider> createState() => _GoalSliderState();
}

class _GoalSliderState extends State<_GoalSlider> {
  late int _minutes;

  @override
  void initState() {
    super.initState();
    _minutes = widget.initialMinutes;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'Daily goal',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              '$_minutes minutes',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          'Minutes of practice you aim to complete each day.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Slider(
          value: _minutes.toDouble(),
          min: 5,
          max: 60,
          divisions: 11,
          label: '$_minutes min',
          onChanged: (double value) {
            setState(() => _minutes = (value / 5).round() * 5);
          },
          onChangeEnd: (double value) {
            widget.onSave((value / 5).round() * 5);
          },
        ),
      ],
    );
  }
}
