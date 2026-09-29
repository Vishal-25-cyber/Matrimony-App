import 'package:flutter/material.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/registration_screen.dart';
import '../features/auth/splash_screen.dart';
import '../features/main_navigation_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String mainNav = '/main';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegistrationScreen());
      case mainNav:
        return MaterialPageRoute(builder: (_) => const MainNavigationScreen());
      default:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
    }
  }
}
