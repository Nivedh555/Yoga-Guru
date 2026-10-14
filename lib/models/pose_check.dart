const double poseCheckPassScore = 0.75;

class PoseCheckItem {
  const PoseCheckItem({required this.label, required this.passed});

  final String label;
  final bool passed;
}

class PoseCheckResult {
  const PoseCheckResult({
    required this.score,
    required this.items,
    this.bodyVisible = true,
  });

  final double score;
  final List<PoseCheckItem> items;
  final bool bodyVisible;

  bool get isPassing => bodyVisible && score >= poseCheckPassScore;

  static const PoseCheckResult hidden = PoseCheckResult(
    score: 0,
    items: <PoseCheckItem>[],
    bodyVisible: false,
  );
}
