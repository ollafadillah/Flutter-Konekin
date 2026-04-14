import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/project_provider.dart';
import '../../../data/models/project_model.dart';
import '../../widgets/project_card.dart';
import 'project_detail_screen.dart';

class SavedProjectsScreen extends StatefulWidget {
  const SavedProjectsScreen({super.key});

  @override
  State<SavedProjectsScreen> createState() => _SavedProjectsScreenState();
}

class _SavedProjectsScreenState extends State<SavedProjectsScreen> {
  @override
  void initState() {
    super.initState();
    _loadSavedProjects();
  }

  Future<void> _loadSavedProjects() async {
    final provider = Provider.of<ProjectProvider>(context, listen: false);
    await provider.loadSavedProjects();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProjectProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Proyek Disimpan'),
        centerTitle: true,
      ),
      body: _buildBody(provider),
    );
  }

  Widget _buildBody(ProjectProvider provider) {
    if (provider.isLoading && provider.savedProjects.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (provider.savedProjects.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bookmark_border, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'Belum ada proyek yang disimpan',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              'Simpan proyek yang menarik untuk diajukan nanti',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: _loadSavedProjects,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.savedProjects.length,
        itemBuilder: (context, index) {
          final project = provider.savedProjects[index];
          return ProjectCard(
            project: project,
            showSaveButton: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProjectDetailScreen(projectId: project.id),
                ),
              ).then((_) => _loadSavedProjects());
            },
          );
        },
      ),
    );
  }
}