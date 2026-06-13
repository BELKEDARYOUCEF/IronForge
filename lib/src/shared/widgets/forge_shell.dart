import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_theme.dart';
import 'forge_bottom_nav.dart';

class ForgeShell extends StatelessWidget {
  const ForgeShell({
    required this.title,
    required this.child,
    this.actions,
    this.showBottomNav = true,
    super.key,
  });

  final String title;
  final Widget child;
  final List<Widget>? actions;
  final bool showBottomNav;

  bool _canGoBack(String path) {
    return path != '/' && path != '/history' && path != '/exercises' && path != '/progress' && path != '/routines';
  }

  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;

    return Scaffold(
      backgroundColor: IFColors.black,
      appBar: AppBar(
        title: Text(title),
        leading: _canGoBack(path)
            ? IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.go('/'))
            : null,
        actions: actions,
      ),
      body: SafeArea(bottom: false, child: child),
      bottomNavigationBar: showBottomNav ? const ForgeBottomNav() : null,
    );
  }
}
