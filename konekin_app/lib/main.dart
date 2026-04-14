import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'presentations/providers/auth_provider.dart';
import 'presentations/providers/project_provider.dart';
import 'presentations/providers/proposal_provider.dart';
import 'presentations/screens/home/home_wrapper.dart';
import 'core/themes/app_theme.dart';
import 'data/datasources/local/shared_prefs_service.dart';
import 'presentations/screens/auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPrefsService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProjectProvider()),
        ChangeNotifierProvider(create: (_) => ProposalProvider()),
      ],
      child: MaterialApp(
        title: 'Konekin',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme(),
        initialRoute: '/',
        onGenerateRoute: (settings) {
            if (settings.name == '/') {
            return MaterialPageRoute(builder: (_) => const LoginScreen());  // <-- Langsung ke Login
       }
           return null;
      },
      ),
    );
  }
}