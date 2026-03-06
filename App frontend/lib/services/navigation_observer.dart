import 'package:flutter/material.dart';
import '../providers/app_state_provider.dart';

class AppNavigationObserver extends NavigatorObserver {
  final AppStateProvider appState;

  AppNavigationObserver(this.appState);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    // Trigger transition when a new route is pushed
    // Avoid triggering for the initial route or if it's a dialog
    if (previousRoute != null && route is MaterialPageRoute) {
      appState.triggerTransition(message: 'Entering ${route.settings.name ?? 'Screen'}...');
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    // Optional: Trigger transition on pop if desired
    // appState.triggerTransition(message: 'Going Back...');
  }
}
