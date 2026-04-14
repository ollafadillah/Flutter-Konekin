import 'package:flutter/material.dart';
import '../presentations/screens/auth/login_screen.dart';
import '../presentations/screens/auth/register_screen.dart';
import '../presentations/screens/home/home_wrapper.dart';

class AppRoutes {
  static const String initial = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case initial:
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeWrapper());
      default:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
    }
  }
}