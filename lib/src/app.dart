import 'package:flutter/material.dart';

import 'core/app_theme.dart';
import 'core/router.dart';

class IronForgeApp extends StatelessWidget {
  const IronForgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'IronForge',
      debugShowCheckedModeBanner: false,
      theme: buildIronForgeTheme(),
      routerConfig: appRouter,
    );
  }
}

