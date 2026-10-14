import 'package:flutter/material.dart';

import '../models/yoga_pose.dart';
import 'explore_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'progress_screen.dart';

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;
  int _exploreRequestId = 0;
  PoseDifficulty? _exploreFilter;

  void _openExplore({PoseDifficulty? difficulty}) {
    setState(() {
      _exploreRequestId += 1;
      _exploreFilter = difficulty;
      _index = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: _index,
          children: <Widget>[
            HomeScreen(onOpenExplore: _openExplore),
            ExploreScreen(
              initialDifficulty: _exploreFilter,
              filterRequestId: _exploreRequestId,
            ),
            const ProgressScreen(),
            const ProfileScreen(),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (int index) => setState(() => _index = index),
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.self_improvement_outlined),
            selectedIcon: Icon(Icons.self_improvement),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view_rounded),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights),
            label: 'Progress',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
