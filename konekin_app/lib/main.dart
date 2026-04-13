import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/login_page.dart';
import 'features/home/umkm_dashboard.dart';
import 'features/home/creative_dashboard.dart';
import 'features/project/create_project_page.dart';
import 'features/project/project_list_page.dart';
import 'features/project/project_detail_page.dart';
import 'features/project/find_projects_page.dart';
import 'features/project/saved_projects_page.dart';
import 'features/proposal/my_proposals_page.dart';
import 'features/proposal/submit_proposal_page.dart';
import 'features/profile/umkm_profile_page.dart';
import 'features/profile/creative_profile_page.dart';
import 'features/profile/portfolio_page.dart';
import 'services/auth_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
      ],
      child: MaterialApp(
        title: 'Konekin',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme(),
        initialRoute: '/',
        routes: {
          '/': (context) => const AuthWrapper(),
          '/login': (context) => const LoginPage(),
          '/umkm-dashboard': (context) => const UmkmDashboard(),
          '/creative-dashboard': (context) => const CreativeDashboard(),
          '/create-project': (context) => const CreateProjectPage(),
          '/my-projects': (context) => const ProjectListPage(),
          '/find-projects': (context) => const FindProjectsPage(),
          '/saved-projects': (context) => const SavedProjectsPage(),
          '/my-proposals': (context) => const MyProposalsPage(),
          '/umkm-profile': (context) => const UmkmProfilePage(),
          '/creative-profile': (context) => const CreativeProfilePage(),
          '/portfolio': (context) => const PortfolioPage(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    
    return FutureBuilder(
      future: authService.checkAuthStatus(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        if (authService.isLoggedIn) {
          if (authService.userRole == 'umkm') {
            return const UmkmDashboardWrapper();
          } else {
            return const CreativeDashboardWrapper();
          }
        } else {
          return const LoginPage();
        }
      },
    );
  }
}

class UmkmDashboardWrapper extends StatefulWidget {
  const UmkmDashboardWrapper({super.key});

  @override
  State<UmkmDashboardWrapper> createState() => _UmkmDashboardWrapperState();
}

class _UmkmDashboardWrapperState extends State<UmkmDashboardWrapper> {
  int _currentIndex = 0;
  
  final List<Widget> _pages = [
    const UmkmDashboard(),
    const ProjectListPage(),
    const MyProposalsPage(),
    const UmkmProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.folder), label: 'Proyek'),
          BottomNavigationBarItem(icon: Icon(Icons.description), label: 'Proposal'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.pushNamed(context, '/create-project');
              },
              icon: const Icon(Icons.add),
              label: const Text('Buat Proyek'),
              backgroundColor: AppTheme.primaryColor,
            )
          : null,
    );
  }
}

class CreativeDashboardWrapper extends StatefulWidget {
  const CreativeDashboardWrapper({super.key});

  @override
  State<CreativeDashboardWrapper> createState() => _CreativeDashboardWrapperState();
}

class _CreativeDashboardWrapperState extends State<CreativeDashboardWrapper> {
  int _currentIndex = 0;
  
  final List<Widget> _pages = [
    const CreativeDashboard(),
    const FindProjectsPage(),
    const MyProposalsPage(),
    const SavedProjectsPage(),
    const CreativeProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Cari'),
          BottomNavigationBarItem(icon: Icon(Icons.description), label: 'Proposal'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'Simpan'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}