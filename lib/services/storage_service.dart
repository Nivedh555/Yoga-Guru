import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/session_record.dart';

class StorageService {
  StorageService(this._prefs);

  final SharedPreferences _prefs;

  static const String _keyDisplayName = 'profile.displayName';
  static const String _keyThemeMode = 'settings.themeMode';
  static const String _keyDailyGoal = 'settings.dailyGoalMinutes';
  static const String _keyRecords = 'progress.records';

  static const int defaultDailyGoalMinutes = 15;

  static Future<StorageService> load() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  String get displayName {
    final String? value = _prefs.getString(_keyDisplayName);
    if (value == null || value.trim().isEmpty) {
      return 'Yoga Practitioner';
    }
    return value.trim();
  }

  Future<bool> setDisplayName(String value) async {
    try {
      return await _prefs.setString(_keyDisplayName, value.trim());
    } catch (_) {
      return false;
    }
  }

  ThemeMode get themeMode {
    final String? raw = _prefs.getString(_keyThemeMode);
    return switch (raw) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<bool> setThemeMode(ThemeMode mode) async {
    try {
      return await _prefs.setString(_keyThemeMode, mode.name);
    } catch (_) {
      return false;
    }
  }

  int get dailyGoalMinutes {
    final int stored = _prefs.getInt(_keyDailyGoal) ?? defaultDailyGoalMinutes;
    return stored.clamp(5, 90);
  }

  Future<bool> setDailyGoalMinutes(int minutes) async {
    try {
      return await _prefs.setInt(_keyDailyGoal, minutes.clamp(5, 90));
    } catch (_) {
      return false;
    }
  }

  List<SessionRecord> loadRecords() {
    final String? raw = _prefs.getString(_keyRecords);
    if (raw == null || raw.isEmpty) {
      return const <SessionRecord>[];
    }
    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is! List) {
        return const <SessionRecord>[];
      }
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(SessionRecord.fromJson)
          .whereType<SessionRecord>()
          .toList();
    } catch (_) {
      return const <SessionRecord>[];
    }
  }

  Future<bool> saveRecords(List<SessionRecord> records) async {
    try {
      final String raw = jsonEncode(
        records.map((SessionRecord record) => record.toJson()).toList(),
      );
      return await _prefs.setString(_keyRecords, raw);
    } catch (_) {
      return false;
    }
  }

  Future<bool> clearProgress() async {
    try {
      return await _prefs.remove(_keyRecords);
    } catch (_) {
      return false;
    }
  }
}
