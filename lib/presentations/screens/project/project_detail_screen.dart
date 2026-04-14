import 'package:flutter/material.dart';
import '../../../data/models/project_model.dart';
import '../../../services/api_service.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/utils/helpers.dart';

class ProjectDetailScreen extends StatefulWidget {
  final String projectId;
  const ProjectDetailScreen({super.key, required this.projectId});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  final ApiService _apiService = ApiService();
  ProjectModel? _project;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final response = await _apiService.getProjectDetail(widget.projectId);
    if (mounted) {
      setState(() {
        _project = response.data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_project == null) {
      return const Scaffold(body: Center(child: Text('Proyek tidak ditemukan')));
    }

    return Scaffold(
      appBar: AppBar(title: Text(_project!.title), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_project!.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Kategori: ${_project!.category}'),
            Text('Budget: ${_project!.formattedBudget}'),
            Text('Deadline: ${_project!.formattedDeadline}'),
            Text('Status: ${_project!.statusText}'),
            const Divider(),
            const Text('Deskripsi', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(_project!.description),
          ],
        ),
      ),
    );
  }
}