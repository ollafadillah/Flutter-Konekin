import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/project_provider.dart';
import '../../../data/models/project_model.dart';
import '../../widgets/project_card.dart';
import 'project_detail_screen.dart';

class FindProjectsScreen extends StatefulWidget {
  const FindProjectsScreen({super.key});

  @override
  State<FindProjectsScreen> createState() => _FindProjectsScreenState();
}

class _FindProjectsScreenState extends State<FindProjectsScreen> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'Semua';
  
  final List<String> categories = [
    'Semua', 'Video Editing', 'Graphic Design', 'UI/UX Design',
    'Web Development', 'Mobile Development', 'Digital Marketing',
    'Content Writing', 'Photography', 'Animation'
  ];

  @override
  void initState() {
    super.initState();
    _loadProjects();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    _loadProjects(refresh: true);
  }

  void _loadProjects({bool refresh = true}) {
    final provider = Provider.of<ProjectProvider>(context, listen: false);
    provider.loadAllProjects(
      category: _selectedCategory == 'Semua' ? null : _selectedCategory,
      search: _searchController.text.isEmpty ? null : _searchController.text,
      refresh: refresh,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cari Proyek'),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari proyek...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Consumer<ProjectProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.allProjects.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (provider.allProjects.isEmpty) {
            return const Center(child: Text('Tidak ada proyek ditemukan'));
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.allProjects.length,
            itemBuilder: (context, index) {
              final project = provider.allProjects[index];
              return ProjectCard(
                project: project,
                showSaveButton: true,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProjectDetailScreen(projectId: project.id),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}