import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/helpers.dart';
import '../../models/project_model.dart';
import '../../models/proposal_model.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../proposal/submit_proposal_page.dart';

class ProjectDetailPage extends StatefulWidget {
  final String projectId;
  const ProjectDetailPage({super.key, required this.projectId});

  @override
  State<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage> {
  final _apiService = ApiService();
  ProjectModel? _project;
  List<ProposalModel> _proposals = [];
  bool _isLoading = true;
  bool _isSaved = false;
  String _userRole = '';

  @override
  void initState() {
    super.initState();
    _loadData();
    _getUserRole();
  }

  Future<void> _getUserRole() async {
    final authService = AuthService();
    await authService.checkAuthStatus();
    setState(() {
      _userRole = authService.userRole;
    });
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    final projectResponse = await _apiService.getProjectDetail(widget.projectId);
    final proposalsResponse = await _apiService.getProjectProposals(widget.projectId);
    
    if (mounted) {
      setState(() {
        _project = projectResponse.data;
        _proposals = proposalsResponse.data;
        _isSaved = _project?.isSaved ?? false;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleSave() async {
    if (_isSaved) {
      final response = await _apiService.unsaveProject(widget.projectId);
      if (response.success) {
        setState(() => _isSaved = false);
        Helpers.showSuccess(context, 'Dihapus dari simpanan');
      }
    } else {
      final response = await _apiService.saveProject(widget.projectId);
      if (response.success) {
        setState(() => _isSaved = true);
        Helpers.showSuccess(context, 'Disimpan');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_project == null) {
      return const Scaffold(
        body: Center(child: Text('Proyek tidak ditemukan')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(Helpers.truncateText(_project!.title, 20)),
        actions: [
          IconButton(
            onPressed: _toggleSave,
            icon: Icon(_isSaved ? Icons.bookmark : Icons.bookmark_border),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _project!.statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _project!.statusText,
                          style: TextStyle(color: _project!.statusColor),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _project!.formattedBudget,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _project!.title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildInfoChip(Icons.category, _project!.category),
                      _buildInfoChip(Icons.calendar_today, 'Deadline: ${_project!.formattedDeadline}'),
                      _buildInfoChip(Icons.access_time, '${_project!.daysRemaining} hari lagi'),
                      _buildInfoChip(Icons.people, '${_project!.proposalCount} proposal'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  const Text(
                    'Deskripsi Proyek',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _project!.description,
                    style: const TextStyle(height: 1.5),
                  ),
                  if (_project!.requiredSkills.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Keahlian yang Dibutuhkan',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _project!.requiredSkills.map((skill) {
                        return Chip(
                          label: Text(skill),
                          backgroundColor: AppTheme.accentColor.withOpacity(0.3),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Proposals Section (for UMKM)
            if (_userRole == 'umkm' && _proposals.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Proposal Masuk (${_proposals.length})',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    ..._proposals.map((proposal) => _buildProposalCard(proposal)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Submit Proposal Button (for Creative)
            if (_userRole == 'creative' && _project!.status == 'open')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SubmitProposalPage(projectId: _project!.id),
                      ),
                    ).then((_) => _loadData());
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Ajukan Proposal'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.textSecondary),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildProposalCard(ProposalModel proposal) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppTheme.accentColor,
                  child: Text(
                    proposal.creativeName?.substring(0, 1).toUpperCase() ?? '?',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        proposal.creativeName ?? 'Creative Worker',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        proposal.formattedBidAmount,
                        style: TextStyle(color: AppTheme.primaryColor),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: proposal.statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    proposal.statusText,
                    style: TextStyle(fontSize: 11, color: proposal.statusColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              Helpers.truncateText(proposal.coverLetter, 120),
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 8),
            Text(
              'Estimasi: ${proposal.estimatedDays} hari',
              style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),
            
            if (proposal.status == 'pending' && _userRole == 'umkm')
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          final response = await _apiService.acceptProposal(proposal.id);
                          if (mounted) {
                            if (response.success) {
                              Helpers.showSuccess(context, 'Proposal diterima');
                              _loadData();
                            } else {
                              Helpers.showError(context, response.message);
                            }
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppTheme.successColor),
                        ),
                        child: Text(
                          'Terima',
                          style: TextStyle(color: AppTheme.successColor),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          final response = await _apiService.rejectProposal(proposal.id);
                          if (mounted) {
                            if (response.success) {
                              Helpers.showSuccess(context, 'Proposal ditolak');
                              _loadData();
                            } else {
                              Helpers.showError(context, response.message);
                            }
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppTheme.errorColor),
                        ),
                        child: Text(
                          'Tolak',
                          style: TextStyle(color: AppTheme.errorColor),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}