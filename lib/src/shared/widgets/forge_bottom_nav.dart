import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_theme.dart';

class ForgeBottomNav extends StatelessWidget {
  const ForgeBottomNav({super.key});

  int _indexForPath(String path) {
    if (path.startsWith('/history')) return 1;
    if (path.startsWith('/exercises')) return 2;
    if (path.startsWith('/progress')) return 3;
    if (path.startsWith('/routines')) return 4;
    return 0;
  }

  void _go(BuildContext context, int index) {
    final routes = ['/', '/history', '/exercises', '/progress', '/routines'];
    context.go(routes[index]);
  }

  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    final selectedIndex = _indexForPath(path);

    return Container(
      decoration: const BoxDecoration(
        color: IFColors.black,
        border: Border(top: BorderSide(color: IFColors.borderSoft)),
      ),
      child: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) => _go(context, index),
        backgroundColor: IFColors.black,
        indicatorColor: IFColors.red,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.history_rounded), label: 'History'),
          NavigationDestination(icon: Icon(Icons.fitness_center_rounded), label: 'Exercises'),
          NavigationDestination(icon: Icon(Icons.bar_chart_rounded), label: 'Progress'),
          NavigationDestination(icon: Icon(Icons.rocket_launch_rounded), label: 'Programs'),
        ],
      ),
    );
  }
}
