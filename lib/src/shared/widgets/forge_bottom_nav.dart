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
    const items = [
      _ForgeNavItem(Icons.home_rounded, 'Home'),
      _ForgeNavItem(Icons.history_rounded, 'History'),
      _ForgeNavItem(Icons.fitness_center_rounded, 'Exercises'),
      _ForgeNavItem(Icons.bar_chart_rounded, 'Progress'),
      _ForgeNavItem(Icons.rocket_launch_rounded, 'Programs'),
    ];

    return SafeArea(
      top: false,
      child: Container(
        height: 66,
        decoration: const BoxDecoration(
          color: IFColors.black,
          border: Border(top: BorderSide(color: IFColors.borderSoft)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        child: Row(
          children: [
            for (var index = 0; index < items.length; index++)
              Expanded(
                child: _ForgeBottomNavButton(
                  item: items[index],
                  selected: selectedIndex == index,
                  onTap: () => _go(context, index),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ForgeNavItem {
  const _ForgeNavItem(this.icon, this.label);

  final IconData icon;
  final String label;
}

class _ForgeBottomNavButton extends StatelessWidget {
  const _ForgeBottomNavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _ForgeNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? IFColors.red : IFColors.textFaint;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
        decoration: BoxDecoration(
          color: selected
              ? IFColors.red.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: selected
                  ? IFColors.red.withValues(alpha: 0.38)
                  : Colors.transparent),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(item.icon, color: color, size: 19),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                item.label,
                maxLines: 1,
                style: TextStyle(
                  color: color,
                  fontSize: 9,
                  fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
