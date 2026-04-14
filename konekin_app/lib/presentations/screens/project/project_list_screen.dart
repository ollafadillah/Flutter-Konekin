import 'package:flutter/material.dart';
import '../../../data/models/project_model.dart';
import '../../../services/api_service.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/utils/helpers.dart';
import 'create_project_screen.dart';
import 'project_detail_screen.dart';

class ProjectListScreen extends StatefulWidget {
  const ProjectListScreen({super.key});

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  final ApiService _apiService = ApiService();
  List<ProjectModel> _projects = [];
  bool _isLoading = true;
  String _selectedFilter = 'Semua';
  final List<String> _filters = ['Semua', 'Open', 'Berjalan', 'Selesai'];

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    setState(() => _isLoading = true);
    final response = await _apiService.getMyProjects();
    if (mounted) {
      setState(() {
        _projects = response.data ?? [];
        _isLoading = false;
      });
    }
  }

  List<ProjectModel> get _filteredProjects {
    if (_selectedFilter == 'Semua') return _projects;
    String statusMap = '';
    switch (_selectedFilter) {
      case 'Open':
        statusMap = 'open';
        break;
      case 'Berjalan':
        statusMap = 'in_progress';
        break;
      case 'Selesai':
        statusMap = 'completed';
        break;
    }
    return _projects.where((p) => p.status == statusMap).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Proyek Saya'), centerTitle: true),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredProjects.isEmpty
              ? const Center(child: Text('Belum ada proyek'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _filteredProjects.length,
                  itemBuilder: (context, index) {
                    final project = _filteredProjects[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(project.title),
                        subtitle: Text(project.category),
                        trailing: Text(project.formattedBudget),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProjectDetailScreen(projectId: project.id),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateProjectScreen()),
          ).then((_) => _loadProjects());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}