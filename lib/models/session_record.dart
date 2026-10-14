class SessionRecord {
  const SessionRecord({
    required this.id,
    required this.title,
    required this.completedAt,
    required this.seconds,
    required this.poseCount,
  });

  final String id;
  final String title;
  final DateTime completedAt;
  final int seconds;
  final int poseCount;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'title': title,
    'completedAt': completedAt.toIso8601String(),
    'seconds': seconds,
    'poseCount': poseCount,
  };

  static SessionRecord? fromJson(Map<String, dynamic> json) {
    try {
      final DateTime? completedAt = DateTime.tryParse(
        json['completedAt'] as String? ?? '',
      );
      if (completedAt == null) {
        return null;
      }
      return SessionRecord(
        id:
            json['id'] as String? ??
            completedAt.microsecondsSinceEpoch.toString(),
        title: json['title'] as String? ?? 'Practice session',
        completedAt: completedAt,
        seconds: (json['seconds'] as num?)?.toInt() ?? 0,
        poseCount: (json['poseCount'] as num?)?.toInt() ?? 0,
      );
    } catch (_) {
      return null;
    }
  }
}
