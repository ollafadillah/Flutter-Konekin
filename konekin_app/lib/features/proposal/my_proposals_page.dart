import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/helpers.dart';
import '../../models/proposal_model.dart';
import '../../services/api_service.dart';
import '../project/project_detail_page.dart';
import '../project/find_projects_page.dart';

class MyProposalsPage extends StatefulWidget {
  const MyProposalsPage({super.key});

  @override
  State<MyProposalsPage> createState() => _MyProposalsPageState();
}

class _MyProposalsPageState extends State<MyProposalsPage> {
  final _apiService = ApiService();
  List<ProposalModel> _proposals = [];
  bool _isLoading = true;
  String _selectedFilter = 'Semua';
  
  final List<String> _filters = ['Semua', 'Menunggu', 'Diterima', 'Ditolak'];

  @override
  void initState() {
    super.initState();
    _loadProposals();
  }

  Future<void> _loadProposals() async {
    setState(() => _isLoading = true);
    final response = await _apiService.getMyProposals();
    
    if (mounted) {
      setState(() {
        _proposals = response.data;
        _isLoading = false;
      });
    }
  }

  List<ProposalModel> get _filteredProposals {
    if (_selectedFilter == 'Semua') return _proposals;
    String statusMap = '';
    switch (_selectedFilter) {
      case 'Menunggu':
        statusMap = 'pending';
        break;
      case 'Diterima':
        statusMap = 'accepted';
        break;
      case 'Ditolak':
        statusMap = 'rejected';
        break;
    }
    return _proposals.where((p) => p.status == statusMap).toList();
  }

  int get _totalProposals => _proposals.length;
  int get _pendingProposals => _proposals.where((p) => p.status == 'pending').length;
  int get _acceptedProposals => _proposals.where((p) => p.status == 'accepted').length;
  int get _rejectedProposals => _proposals.where((p) => p.status == 'rejected').length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Proposal Saya'),
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
                _buildStat('Total', _totalProposals.toString()),
                _buildStat('Menunggu', _pendingProposals.toString()),
                _buildStat('Diterima', _acceptedProposals.toString()),
                _buildStat('Ditolak', _rejectedProposals.toString()),
              ],
            ),
          ),
          
          // Proposals List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredProposals.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.description_outlined, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              _selectedFilter == 'Semua'
                                  ? 'Belum ada proposal yang dikirim'
                                  : 'Tidak ada proposal $_selectedFilter',
                              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Mulai kirim proposal untuk mendapatkan proyek pertama Anda',
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
                        onRefresh: _loadProposals,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredProposals.length,
                          itemBuilder: (context, index) {
                            final proposal = _filteredProposals[index];
                            return _buildProposalCard(proposal);
                          },
                        ),
                      ),
          ),
        ],
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

  Widget _buildProposalCard(ProposalModel proposal) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProjectDetailPage(projectId: proposal.projectId),
            ),
          );
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
                    child: Icon(Icons.work, color: AppTheme.primaryColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          proposal.projectTitle,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          proposal.formattedDate,
                          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
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
              const SizedBox(height: 12),
              Text(
                Helpers.truncateText(proposal.coverLetter, 120),
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      proposal.formattedBidAmount,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${proposal.estimatedDays} hari',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}