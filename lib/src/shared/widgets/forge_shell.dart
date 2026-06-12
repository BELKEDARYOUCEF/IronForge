import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ForgeShell extends StatelessWidget {
  const ForgeShell({required this.title, required this.child, super.key});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
        leading: GoRouterState.of(context).uri.path == '/'
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.go('/'),
              ),
      ),
      body: SafeArea(child: child),
    );
  }
}

