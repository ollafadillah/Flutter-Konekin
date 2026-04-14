import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/themes/app_theme.dart';
import '../../providers/project_provider.dart';
import '../../providers/auth_provider.dart';
import '../project/create_project_screen.dart';
import '../project/project_list_screen.dart';
import '../proposal/my_proposals_screen.dart';
import '../profile/umkm_profile_screen.dart';

class UmkmHomeScreen extends StatefulWidget {
  const UmkmHomeScreen({super.key});

  @override
  State<UmkmHomeScreen> createState() => _UmkmHomeScreenState();
}

class _UmkmHomeScreenState extends State<UmkmHomeScreen> {
  int _currentIndex = 0;
  
  late List<Widget> _pages;
  
  @override
  void initState() {
    super.initState();
    _pages = [
      const UmkmDashboardContent(),
      const ProjectListScreen(),
      const MyProposalsScreen(),
      const UmkmProfileScreen(),
    ];
  }

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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreateProjectScreen()),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Buat Proyek'),
              backgroundColor: AppTheme.primaryColor,
            )
          : null,
    );
  }
}

class UmkmDashboardContent extends StatelessWidget {
  const UmkmDashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userName = authProvider.userName.isNotEmpty ? authProvider.userName : 'User';
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Dashboard UMKM'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.store,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Selamat Datang, $userName',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Platform kolaborasi UMKM & Creative Worker',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CreateProjectScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                      ),
                      child: const Text('Buat Proyek Baru'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}