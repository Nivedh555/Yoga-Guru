import 'package:flutter/material.dart';

import '../models/session_record.dart';
import 'storage_service.dart';

class AppState extends ChangeNotifier {
  AppState(this._storage)
    : _displayName = _storage.displayName,
      _themeMode = _storage.themeMode,
      _dailyGoalMinutes = _storage.dailyGoalMinutes,
      _records = _storage.loadRecords();

  final StorageService _storage;

  String _displayName;
  ThemeMode _themeMode;
  int _dailyGoalMinutes;
  List<SessionRecord> _records;

  String get displayName => _displayName;

  ThemeMode get themeMode => _themeMode;

  int get dailyGoalMinutes => _dailyGoalMinutes;

  List<SessionRecord> get records => List<SessionRecord>.unmodifiable(_records);

  String get initials {
    final List<String> parts = _displayName
        .trim()
        .split(RegExp(r'\s+'))
        .where((String part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) {
      return 'YG';
    }
    if (parts.length == 1) {
      return parts.first.characters.take(2).toString().toUpperCase();
    }
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
  }

  Future<bool> setDisplayName(String value) async {
    final String trimmed = value.trim();
    if (trimmed.isEmpty) {
      return false;
    }
    final bool saved = await _storage.setDisplayName(trimmed);
    if (saved) {
      _displayName = trimmed;
      notifyListeners();
    }
    return saved;
  }

  Future<bool> setThemeMode(ThemeMode mode) async {
    final bool saved = await _storage.setThemeMode(mode);
    if (saved) {
      _themeMode = mode;
      notifyListeners();
    }
    return saved;
  }

  Future<bool> setDailyGoalMinutes(int minutes) async {
    final bool saved = await _storage.setDailyGoalMinutes(minutes);
    if (saved) {
      _dailyGoalMinutes = minutes.clamp(5, 90);
      notifyListeners();
    }
    return saved;
  }

  Future<bool> addRecord(SessionRecord record) async {
    final List<SessionRecord> updated = <SessionRecord>[..._records, record]
      ..sort(
        (SessionRecord a, SessionRecord b) =>
            a.completedAt.compareTo(b.completedAt),
      );
    final bool saved = await _storage.saveRecords(updated);
    if (saved) {
      _records = updated;
      notifyListeners();
    }
    return saved;
  }

  Future<bool> resetProgress() async {
    final bool cleared = await _storage.clearProgress();
    if (cleared) {
      _records = const <SessionRecord>[];
      notifyListeners();
    }
    return cleared;
  }

  int get totalSessions => _records.length;

  int get totalSeconds =>
      _records.fold<int>(0, (int sum, SessionRecord r) => sum + r.seconds);

  int get totalMinutes => (totalSeconds / 60).round();

  int get todaySeconds {
    final DateTime now = DateTime.now();
    return _records
        .where(
          (SessionRecord r) =>
              r.completedAt.year == now.year &&
              r.completedAt.month == now.month &&
              r.completedAt.day == now.day,
        )
        .fold<int>(0, (int sum, SessionRecord r) => sum + r.seconds);
  }

  int get todayMinutes => (todaySeconds / 60).round();

  double get todayGoalProgress {
    final int goalSeconds = _dailyGoalMinutes * 60;
    if (goalSeconds <= 0) {
      return 0;
    }
    return (todaySeconds / goalSeconds).clamp(0.0, 1.0);
  }

  int get streakDays {
    if (_records.isEmpty) {
      return 0;
    }
    final Set<DateTime> days = _records
        .map(
          (SessionRecord r) => DateTime(
            r.completedAt.year,
            r.completedAt.month,
            r.completedAt.day,
          ),
        )
        .toSet();
    final DateTime now = DateTime.now();
    DateTime cursor = DateTime(now.year, now.month, now.day);
    if (!days.contains(cursor)) {
      cursor = cursor.subtract(const Duration(days: 1));
      if (!days.contains(cursor)) {
        return 0;
      }
    }
    int streak = 0;
    while (days.contains(cursor)) {
      streak += 1;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  List<DateTime> get lastSevenDays {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    return List<DateTime>.generate(
      7,
      (int index) => today.subtract(Duration(days: 6 - index)),
    );
  }

  List<int> get lastSevenDaysSeconds {
    return lastSevenDays.map((DateTime day) {
      return _records
          .where(
            (SessionRecord r) =>
                r.completedAt.year == day.year &&
                r.completedAt.month == day.month &&
                r.completedAt.day == day.day,
          )
          .fold<int>(0, (int sum, SessionRecord r) => sum + r.seconds);
    }).toList();
  }

  List<SessionRecord> get recentRecords {
    final List<SessionRecord> sorted = <SessionRecord>[..._records]
      ..sort(
        (SessionRecord a, SessionRecord b) =>
            b.completedAt.compareTo(a.completedAt),
      );
    return sorted;
  }
}
