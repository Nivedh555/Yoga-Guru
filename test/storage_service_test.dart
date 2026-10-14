import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yoga_guru/models/session_record.dart';
import 'package:yoga_guru/services/app_state.dart';
import 'package:yoga_guru/services/storage_service.dart';

Future<AppState> createState([Map<String, Object> initial = const {}]) async {
  SharedPreferences.setMockInitialValues(initial);
  final StorageService storage = await StorageService.load();
  return AppState(storage);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('defaults are sensible on first launch', () async {
    final AppState state = await createState();
    expect(state.displayName, 'Yoga Practitioner');
    expect(state.themeMode, ThemeMode.system);
    expect(state.dailyGoalMinutes, greaterThan(0));
    expect(state.records, isEmpty);
    expect(state.totalSessions, 0);
    expect(state.streakDays, 0);
  });

  test('profile, theme and goal persist across reloads', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final AppState state = AppState(await StorageService.load());

    expect(await state.setDisplayName('Aarav Sharma'), isTrue);
    expect(await state.setThemeMode(ThemeMode.dark), isTrue);
    expect(await state.setDailyGoalMinutes(30), isTrue);

    final AppState reloaded = AppState(await StorageService.load());
    expect(reloaded.displayName, 'Aarav Sharma');
    expect(reloaded.themeMode, ThemeMode.dark);
    expect(reloaded.dailyGoalMinutes, 30);
    expect(reloaded.initials, 'AS');
  });

  test('empty or blank names are rejected', () async {
    final AppState state = await createState();
    expect(await state.setDisplayName('   '), isFalse);
    expect(state.displayName, 'Yoga Practitioner');
  });

  test('session records drive stats and persist', () async {
    final AppState state = await createState();
    final DateTime now = DateTime.now();

    expect(
      await state.addRecord(
        SessionRecord(
          id: 'a',
          title: 'Morning Energiser',
          completedAt: now,
          seconds: 300,
          poseCount: 5,
        ),
      ),
      isTrue,
    );
    expect(
      await state.addRecord(
        SessionRecord(
          id: 'b',
          title: 'Evening Unwind',
          completedAt: now.subtract(const Duration(days: 1)),
          seconds: 180,
          poseCount: 3,
        ),
      ),
      isTrue,
    );

    expect(state.totalSessions, 2);
    expect(state.totalSeconds, 480);
    expect(state.todaySeconds, 300);
    expect(state.streakDays, 2);
    expect(state.recentRecords.first.id, 'a');
    expect(state.lastSevenDaysSeconds.length, 7);

    final AppState reloaded = AppState(await StorageService.load());
    expect(reloaded.totalSessions, 2);
    expect(reloaded.totalSeconds, 480);
  });

  test('corrupted stored data is ignored safely', () async {
    final AppState state = await createState(<String, Object>{
      'progress.records': 'this is not json',
    });
    expect(state.records, isEmpty);
    expect(state.totalSessions, 0);
  });

  test('resetProgress clears stored records', () async {
    final AppState state = await createState();
    await state.addRecord(
      SessionRecord(
        id: 'a',
        title: 'Morning Energiser',
        completedAt: DateTime.now(),
        seconds: 120,
        poseCount: 3,
      ),
    );
    expect(state.totalSessions, 1);

    expect(await state.resetProgress(), isTrue);
    expect(state.totalSessions, 0);

    final AppState reloaded = AppState(await StorageService.load());
    expect(reloaded.totalSessions, 0);
  });
}
