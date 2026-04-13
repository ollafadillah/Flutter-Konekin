import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/helpers.dart';
import '../../models/project_model.dart';
import '../../services/api_service.dart';
import 'project_detail_page.dart';
import 'find_projects_page.dart';

class SavedProjectsPage extends StatefulWidget {
  const SavedProjectsPage({super.key});

  @override
  State<SavedProjectsPage> createState() => _SavedProjectsPageState();
}

class _SavedProjectsPageState extends State<SavedProjectsPage> {
  final _apiService = ApiService();
  List<ProjectModel> _projects = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedProjects();
  }

  Future<void> _loadSavedProjects() async {
    setState(() => _isLoading = true);
    final response = await _apiService.getSavedProjects();
    
    if (mounted) {
      setState(() {
        _projects = response.data;
        _isLoading = false;
      });
    }
  }

  Future<void> _unsaveProject(ProjectModel project) async {
    final confirm = await Helpers.showConfirmationDialog(
      context,
      title: 'Hapus dari Simpanan',
      message: 'Apakah Anda yakin ingin menghapus proyek ini dari daftar simpanan?',
    );
    
    if (confirm) {
      final response = await _apiService.unsaveProject(project.id);
      if (response.success) {
        setState(() {
          _projects.removeWhere((p) => p.id == project.id);
        });
        Helpers.showSuccess(context, 'Proyek dihapus dari simpanan');
      } else {
        Helpers.showError(context, response.message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Proyek Disimpan'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _projects.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.bookmark_border, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada proyek yang disimpan',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Simpan proyek yang menarik untuk diajukan nanti',
                        style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const FindProjectsPage()),
                          );
                        },
                        icon: const Icon(Icons.search),
                        label: const Text('Cari Proyek'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadSavedProjects,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _projects.length,
                    itemBuilder: (context, index) {
                      final project = _projects[index];
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
                        onDismissed: (direction) => _unsaveProject(project),
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ProjectDetailPage(projectId: project.id),
                                ),
                              ).then((_) => _loadSavedProjects());
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
                                      IconButton(
                                        onPressed: () => _unsaveProject(project),
                                        icon: const Icon(Icons.bookmark, color: Colors.amber),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    Helpers.truncateText(project.description, 100),
                                    style: const TextStyle(fontSize: 13),
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
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
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
      default:
        return Icons.work;
    }
  }
}