import 'package:flutter/material.dart';

import '../services/app_scope.dart';
import '../services/app_state.dart';
import '../utils/page_transitions.dart';
import '../widgets/stat_tile.dart';
import '../widgets/surface_card.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppState state = AppScope.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
      children: <Widget>[
        Center(
          child: Column(
            children: <Widget>[
              CircleAvatar(
                radius: 46,
                backgroundColor: theme.colorScheme.secondaryContainer,
                child: Text(
                  state.initials,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                state.displayName,
                style: theme.textTheme.headlineSmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                'Local profile • saved on your device',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: () => _editName(context, state),
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Edit name'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 26),
        Row(
          children: <Widget>[
            Expanded(
              child: StatTile(
                value: '${state.totalSessions}',
                label: 'Sessions',
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
        const SizedBox(height: 20),
        SurfaceCard(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: const Text('Settings'),
                subtitle: const Text('Theme, daily goal and data'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context)
                      .push(FadeScaleRoute<void>(page: const SettingsScreen()));
                },
              ),
              const Divider(height: 1, indent: 56),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('About Yoga Guru'),
                subtitle: const Text('Version 1.0.0'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showAbout(context),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: Text(
            'Made by Nivedh',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _editName(BuildContext context, AppState state) async {
    final String? value = await showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) =>
          _EditNameDialog(initialName: state.displayName),
    );
    if (value == null || value.trim().isEmpty) {
      return;
    }
    if (!context.mounted) {
      return;
    }
    final bool saved = await state.setDisplayName(value);
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          saved ? 'Profile name updated.' : 'Could not save your name.',
        ),
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('About Yoga Guru'),
        content: const Text(
          'Yoga Guru is an offline yoga instructor app built with Flutter. '
          'It includes a guided pose library, timed practice sessions, '
          'local progress tracking and an on-device camera form check.\n\n'
          'Version 1.0.0\n'
          'Made by Nivedh',
        ),
        actions: <Widget>[
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _EditNameDialog extends StatefulWidget {
  const _EditNameDialog({required this.initialName});

  final String initialName;

  @override
  State<_EditNameDialog> createState() => _EditNameDialogState();
}

class _EditNameDialogState extends State<_EditNameDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Display name'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        textInputAction: TextInputAction.done,
        maxLength: 40,
        decoration: const InputDecoration(
          labelText: 'Name',
          hintText: 'e.g. Aarav Sharma',
        ),
        onSubmitted: (String value) {
          Navigator.of(context).pop(value);
        },
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
