import 'package:flutter/material.dart';

import 'screens/root_shell.dart';
import 'services/app_scope.dart';
import 'services/app_state.dart';
import 'theme/app_theme.dart';

class YogaGuruApp extends StatelessWidget {
  const YogaGuruApp({super.key, required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: state,
      child: Builder(
        builder: (BuildContext context) {
          final AppState appState = AppScope.of(context);
          return MaterialApp(
            title: 'Yoga Guru',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: appState.themeMode,
            home: const RootShell(),
          );
        },
      ),
    );
  }
}
