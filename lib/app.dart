import 'package:flutter/material.dart';
import 'package:disaster_link/core/router/app_router.dart';
import 'package:disaster_link/presentation/theme/app_theme.dart';

/// Root application widget for DisasterLink.
class DisasterLinkApp extends StatelessWidget {
  const DisasterLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'DisasterLink',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: appRouter,
    );
  }
}
