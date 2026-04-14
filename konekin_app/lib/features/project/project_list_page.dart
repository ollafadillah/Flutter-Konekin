import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/helpers.dart';
import '../../models/project_model.dart';
import '../../services/api_service.dart';
import 'create_project_page.dart';
import 'project_detail_page.dart';

class ProjectListPage extends StatefulWidget {
  const ProjectListPage({super.key});

  @override
  State<ProjectListPage> createState() => _ProjectListPageState();
}

class _ProjectListPageState extends State<ProjectListPage> {
  final _apiService = ApiService();
  List<ProjectModel> _projects = [];
  bool _isLoading = true;
  String _selectedFilter = 'Semua';
  bool _isDeleting = false;

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

  int get _totalProjects => _projects.length;
  int get _openProjects => _projects.where((p) => p.status == 'open').length;
  int get _inProgressProjects => _projects.where((p) => p.status == 'in_progress').length;
  int get _completedProjects => _projects.where((p) => p.status == 'completed').length;

  Future<void> _deleteProject(ProjectModel project) async {
    final confirm = await Helpers.showConfirmationDialog(
      context,
      title: 'Hapus Proyek',
      message: 'Apakah Anda yakin ingin menghapus proyek "${project.title}"?',
    );
    
    if (confirm) {
      setState(() => _isDeleting = true);
      final response = await _apiService.deleteProject(project.id);
      
      if (mounted) {
        setState(() => _isDeleting = false);
        if (response.success) {
          Helpers.showSuccess(context, 'Proyek dihapus');
          _loadProjects();
        } else {
          Helpers.showError(context, response.message);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Proyek Saya'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filters.map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() => _selectedFilter = filter);
                      },
                      backgroundColor: Colors.white,
                      selectedColor: AppTheme.primaryColor.withOpacity(0.1),
                      checkmarkColor: AppTheme.primaryColor,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          
          // Stats Row
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat('Total', _totalProjects.toString()),
                _buildStat('Open', _openProjects.toString()),
                _buildStat('Berjalan', _inProgressProjects.toString()),
                _buildStat('Selesai', _completedProjects.toString()),
              ],
            ),
          ),
          
          // Project List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredProjects.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.folder_open, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              _selectedFilter == 'Semua'
                                  ? 'Belum ada proyek'
                                  : 'Tidak ada proyek ${_selectedFilter.toLowerCase()}',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const CreateProjectPage()),
                                ).then((_) => _loadProjects());
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('Buat Proyek Baru'),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadProjects,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredProjects.length,
                          itemBuilder: (context, index) {
                            final project = _filteredProjects[index];
                            return _buildProjectCard(project);
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateProjectPage()),
          ).then((_) => _loadProjects());
        },
        child: const Icon(Icons.add),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
      ],
    );
  }

  Widget _buildProjectCard(ProjectModel project) {
    return Dismissible(
      key: Key(project.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await Helpers.showConfirmationDialog(
          context,
          title: 'Hapus Proyek',
          message: 'Apakah Anda yakin ingin menghapus proyek ini?',
        );
      },
      onDismissed: (direction) => _deleteProject(project),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProjectDetailPage(projectId: project.id),
              ),
            ).then((_) => _loadProjects());
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppTheme.accentColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getCategoryIcon(project.category),
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            project.title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            project.category,
                            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: project.statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        project.statusText,
                        style: TextStyle(fontSize: 11, color: project.statusColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  Helpers.truncateText(project.description, 100),
                  style: const TextStyle(fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 14, color: AppTheme.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      'Deadline: ${project.formattedDeadline}',
                      style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                    ),
                    const Spacer(),
                    Text(
                      project.formattedBudget,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (project.daysRemaining < 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Melewati deadline',
                      style: TextStyle(fontSize: 11, color: AppTheme.errorColor),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'video editing':
        return Icons.videocam;
      case 'graphic design':
        return Icons.design_services;
      case 'web development':
        return Icons.web;
      case 'mobile development':
        return Icons.mobile_friendly;
      default:
        return Icons.work;
    }
  }
}