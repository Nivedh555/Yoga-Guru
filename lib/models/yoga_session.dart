import 'yoga_pose.dart';

class YogaSession {
  const YogaSession({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.poses,
  });

  final String id;
  final String title;
  final String subtitle;
  final List<YogaPose> poses;

  PoseDifficulty get difficulty => poses
      .map((YogaPose pose) => pose.difficulty)
      .reduce(
        (PoseDifficulty a, PoseDifficulty b) => a.index >= b.index ? a : b,
      );

  int get totalSeconds => poses.fold<int>(
    0,
    (int sum, YogaPose pose) => sum + pose.holdSeconds + 12,
  );

  int get minutes => (totalSeconds / 60).ceil();

  YogaPose get cover => poses.first;
}
