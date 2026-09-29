import 'package:flutter/material.dart';
import '../../features/main_navigation_screen.dart';

class SafeNavigation {
  /// Safely pop the current screen or navigate to MainNavigationScreen if this is the root route,
  /// preventing the app from popping into an empty white screen.
  static void safePop(BuildContext context, {int initialIndex = 0}) {
    if (Navigator.canPop(context) && !(ModalRoute.of(context)?.isFirst ?? true)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MainNavigationScreen(initialIndex: initialIndex),
        ),
      );
    }
  }
}
