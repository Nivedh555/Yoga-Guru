enum PoseDifficulty {
  beginner('Beginner'),
  intermediate('Intermediate'),
  advanced('Advanced');

  const PoseDifficulty(this.label);

  final String label;
}

class YogaPose {
  const YogaPose({
    required this.id,
    required this.name,
    required this.sanskritName,
    required this.imageAsset,
    required this.difficulty,
    required this.holdSeconds,
    required this.focus,
    required this.cue,
    required this.description,
    required this.steps,
    required this.benefits,
    required this.safety,
  });

  final String id;
  final String name;
  final String sanskritName;
  final String imageAsset;
  final PoseDifficulty difficulty;
  final int holdSeconds;
  final String focus;
  final String cue;
  final String description;
  final List<String> steps;
  final List<String> benefits;
  final String safety;

  String get durationLabel => '$holdSeconds second hold';
}
