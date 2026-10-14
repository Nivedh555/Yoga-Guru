import 'package:flutter/material.dart';

import '../data/pose_repository.dart';
import '../models/yoga_pose.dart';
import '../utils/page_transitions.dart';
import '../widgets/empty_state.dart';
import '../widgets/pose_card.dart';
import 'pose_detail_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({
    super.key,
    this.initialDifficulty,
    this.filterRequestId = 0,
  });

  final PoseDifficulty? initialDifficulty;
  final int filterRequestId;

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  PoseDifficulty? _difficulty;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _difficulty = widget.initialDifficulty;
  }

  @override
  void didUpdateWidget(covariant ExploreScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.filterRequestId != oldWidget.filterRequestId) {
      _difficulty = widget.initialDifficulty;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<YogaPose> get _filteredPoses {
    List<YogaPose> poses = PoseRepository.search(_query);
    final PoseDifficulty? difficulty = _difficulty;
    if (difficulty != null) {
      poses = poses
          .where((YogaPose pose) => pose.difficulty == difficulty)
          .toList();
    }
    return poses;
  }

  void _clearFilters() {
    _searchController.clear();
    setState(() {
      _query = '';
      _difficulty = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<YogaPose> poses = _filteredPoses;
    final int columns = MediaQuery.sizeOf(context).width >= 720 ? 3 : 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Pose library', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text(
                '${PoseRepository.all.length} poses with guided instructions',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextField(
            controller: _searchController,
            textInputAction: TextInputAction.search,
            onChanged: (String value) => setState(() => _query = value),
            decoration: InputDecoration(
              hintText: 'Search poses',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear search',
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                    ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 42,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: <Widget>[
              _difficultyChoiceChip(label: 'All', difficulty: null),
              const SizedBox(width: 8),
              _difficultyChoiceChip(
                label: PoseDifficulty.beginner.label,
                difficulty: PoseDifficulty.beginner,
              ),
              const SizedBox(width: 8),
              _difficultyChoiceChip(
                label: PoseDifficulty.intermediate.label,
                difficulty: PoseDifficulty.intermediate,
              ),
              const SizedBox(width: 8),
              _difficultyChoiceChip(
                label: PoseDifficulty.advanced.label,
                difficulty: PoseDifficulty.advanced,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: poses.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: EmptyState(
                      icon: Icons.search_off,
                      title: 'No poses found',
                      message:
                          'Try a different keyword or choose another level.',
                      actionLabel: 'Clear filters',
                      onAction: _clearFilters,
                    ),
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: poses.length,
                  itemBuilder: (BuildContext context, int index) {
                    final YogaPose pose = poses[index];
                    return PoseCard(
                      pose: pose,
                      onTap: () {
                        Navigator.of(context).push(
                          FadeScaleRoute<void>(
                            page: PoseDetailScreen(pose: pose),
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _difficultyChoiceChip({
    required String label,
    required PoseDifficulty? difficulty,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: _difficulty == difficulty,
      onSelected: (bool selected) {
        setState(() {
          _difficulty = selected ? difficulty : null;
        });
      },
    );
  }
}
