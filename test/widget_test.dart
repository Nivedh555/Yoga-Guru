import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yoga_guru/app.dart';
import 'package:yoga_guru/services/app_state.dart';
import 'package:yoga_guru/services/storage_service.dart';

Future<Widget> buildApp() async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  final StorageService storage = await StorageService.load();
  return YogaGuruApp(state: AppState(storage));
}

void usePhoneSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> scrollTo(WidgetTester tester, Finder target) async {
  await tester.scrollUntilVisible(
    target,
    220,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('home screen shows greeting, sessions and levels', (
    WidgetTester tester,
  ) async {
    usePhoneSurface(tester);
    await tester.pumpWidget(await buildApp());
    await tester.pumpAndSettle();

    expect(find.text('Yoga Practitioner'), findsOneWidget);
    expect(find.text('Featured sessions'), findsOneWidget);
    expect(find.text('Start session'), findsOneWidget);

    await scrollTo(tester, find.text('Choose your level'));
    expect(find.text('Choose your level'), findsOneWidget);
    expect(find.text('Beginner'), findsWidgets);

    await scrollTo(tester, find.text('Popular poses'));
    expect(find.text('Popular poses'), findsOneWidget);
  });

  testWidgets('bottom navigation switches to explore and filters by level', (
    WidgetTester tester,
  ) async {
    usePhoneSurface(tester);
    await tester.pumpWidget(await buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Explore'));
    await tester.pumpAndSettle();

    expect(find.text('Pose library'), findsOneWidget);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Beginner'));
    await tester.pumpAndSettle();

    expect(find.text('Mountain Pose'), findsOneWidget);
    expect(find.text('Crow Pose'), findsNothing);

    await tester.tap(find.widgetWithText(ChoiceChip, 'All'));
    await tester.pumpAndSettle();

    expect(find.text('Mountain Pose'), findsOneWidget);
  });

  testWidgets('pose detail opens and the session timer pauses and resets', (
    WidgetTester tester,
  ) async {
    usePhoneSurface(tester);
    await tester.pumpWidget(await buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Explore'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Mountain Pose').first);
    await tester.pumpAndSettle();

    await scrollTo(tester, find.text('How to perform'));
    expect(find.text('How to perform'), findsOneWidget);

    await tester.tap(find.textContaining('Start session'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Start session'));
    await tester.pump();

    final Finder timerText = find.byKey(
      const ValueKey<String>('sessionTimerText'),
    );
    expect(timerText, findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    final String afterTwoTicks = tester.widget<Text>(timerText).data ?? '';

    await tester.tap(find.byIcon(Icons.pause_rounded));
    await tester.pump();
    expect(find.text('paused'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    final String afterPause = tester.widget<Text>(timerText).data ?? '';
    expect(afterPause, afterTwoTicks);

    await tester.tap(find.byTooltip('Reset pose timer'));
    await tester.pump();
    final String afterReset = tester.widget<Text>(timerText).data ?? '';
    expect(afterReset, '0:45');
  });

  testWidgets('theme can be switched to dark and progress screen renders', (
    WidgetTester tester,
  ) async {
    usePhoneSurface(tester);
    await tester.pumpWidget(await buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('Edit name'), findsOneWidget);

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    final MaterialApp app = tester.widget<MaterialApp>(
      find.byType(MaterialApp),
    );
    expect(app.themeMode, ThemeMode.dark);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Progress'));
    await tester.pumpAndSettle();

    expect(find.text('Your progress'), findsOneWidget);
    expect(find.text("Today's practice"), findsOneWidget);

    await scrollTo(tester, find.text('No sessions yet'));
    expect(find.text('No sessions yet'), findsOneWidget);
  });
}
