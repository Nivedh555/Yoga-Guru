import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/yoga_pose.dart';
import '../utils/page_transitions.dart';
import '../widgets/pose_card.dart';
import '../widgets/section_header.dart';
import '../widgets/surface_card.dart';
import 'pose_camera_screen.dart';
import 'session_screen.dart';

class PoseDetailScreen extends StatelessWidget {
  const PoseDetailScreen({super.key, required this.pose});

  final YogaPose pose;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(pose.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: <Widget>[
            Container(
              height: 240,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondaryContainer.withValues(
                  alpha: 0.5,
                ),
                borderRadius: BorderRadius.circular(24),
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
                      size: 80,
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
              ),
            ),
            const SizedBox(height: 18),
            Text(pose.name, style: theme.textTheme.headlineMedium),
            const SizedBox(height: 4),
            Text(
              pose.sanskritName,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                DifficultyPill(difficulty: pose.difficulty),
                _InfoChip(icon: Icons.schedule, label: pose.durationLabel),
                _InfoChip(icon: Icons.spa_outlined, label: pose.focus),
              ],
            ),
            const SizedBox(height: 20),
            Text(pose.description, style: theme.textTheme.bodyLarge),
            const SizedBox(height: 24),
            const SectionHeader(title: 'How to perform'),
            const SizedBox(height: 10),
            SurfaceCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: <Widget>[
                  for (int i = 0; i < pose.steps.length; i++)
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: i == pose.steps.length - 1 ? 0 : 14,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            width: 26,
                            height: 26,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondaryContainer,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${i + 1}',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.onSecondaryContainer,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              pose.steps[i],
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const SectionHeader(title: 'Benefits'),
            const SizedBox(height: 10),
            SurfaceCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: <Widget>[
                  for (int i = 0; i < pose.benefits.length; i++)
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: i == pose.benefits.length - 1 ? 0 : 12,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              pose.benefits[i],
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SurfaceCard(
              color: const Color(0xFFB0764D).withValues(alpha: 0.12),
              showBorder: false,
              padding: const EdgeInsets.all(18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Color(0xFF9C5B32),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Safety notes',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF9C5B32),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(pose.safety, style: theme.textTheme.bodyMedium),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (_supportsCameraCheck)
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    FadeScaleRoute<void>(page: PoseCameraScreen(pose: pose)),
                  );
                },
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('Check my pose with camera'),
              ),
            if (_supportsCameraCheck) const SizedBox(height: 10),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  FadeScaleRoute<void>(
                    page: SessionScreen(
                      title: pose.name,
                      poses: <YogaPose>[pose],
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text('Start session • ${pose.holdSeconds}s'),
            ),
          ],
        ),
      ),
    );
  }

  static bool get _supportsCameraCheck =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 5),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
