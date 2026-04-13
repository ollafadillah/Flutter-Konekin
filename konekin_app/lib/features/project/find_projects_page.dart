import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/helpers.dart';
import '../../models/project_model.dart';
import '../../services/api_service.dart';
import 'project_detail_page.dart';

class FindProjectsPage extends StatefulWidget {
  const FindProjectsPage({super.key});

  @override
  State<FindProjectsPage> createState() => _FindProjectsPageState();
}

class _FindProjectsPageState extends State<FindProjectsPage> {
  final _apiService = ApiService();
  List<ProjectModel> _projects = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  final _searchController = TextEditingController();
  String _selectedCategory = 'Semua';
  String _sortBy = 'Terbaru';
  int _currentPage = 1;
  int _totalPages = 1;
  
  final List<String> _categories = [
    'Semua', 'Video Editing', 'Graphic Design', 'UI/UX Design',
    'Web Development', 'Mobile Development', 'Digital Marketing',
    'Content Writing', 'Photography', 'Animation'
  ];
  
  final List<String> _sortOptions = ['Terbaru', 'Termurah', 'Termahal', 'Deadline Terdekat'];

  @override
  void initState() {
    super.initState();
    _loadProjects();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _currentPage = 1;
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    setState(() => _isLoading = true);
    
    final response = await _apiService.getAllProjects(
      category: _selectedCategory == 'Semua' ? null : _selectedCategory,
      search: _searchController.text.isEmpty ? null : _searchController.text,
      page: _currentPage,
      limit: 10,
    );
    
    if (mounted) {
      setState(() {
        if (_currentPage == 1) {
          _projects = response.data;
        } else {
          _projects.addAll(response.data);
        }
        _totalPages = (response.total ?? 0) ~/ 10 + 1;
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || _currentPage >= _totalPages) return;
    setState(() {
      _currentPage++;
      _isLoadingMore = true;
    });
    await _loadProjects();
  }

  List<ProjectModel> get _sortedProjects {
    List<ProjectModel> sorted = List.from(_projects);
    switch (_sortBy) {
      case 'Termurah':
        sorted.sort((a, b) => a.budget.compareTo(b.budget));
        break;
      case 'Termahal':
        sorted.sort((a, b) => b.budget.compareTo(a.budget));
        break;
      case 'Deadline Terdekat':
        sorted.sort((a, b) => a.deadline.compareTo(b.deadline));
        break;
      default:
        sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    return sorted;
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
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Categories Filter
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;
                return FilterChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = category;
                      _currentPage = 1;
                    });
                    _loadProjects();
                  },
                  backgroundColor: Colors.white,
                  selectedColor: AppTheme.primaryColor.withOpacity(0.1),
                  checkmarkColor: AppTheme.primaryColor,
                );
              },
            ),
          ),
          
          // Sort & Results
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Text(
                  '${_projects.length} Proyek Ditemukan',
                  style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  child: DropdownButton<String>(
                    value: _sortBy,
                    items: _sortOptions.map((option) {
                      return DropdownMenuItem(
                        value: option,
                        child: Text(option, style: const TextStyle(fontSize: 13)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _sortBy = value!);
                    },
                    underline: const SizedBox(),
                    icon: const Icon(Icons.sort, size: 18),
                  ),
                ),
              ],
            ),
          ),
          
          // Project List
          Expanded(
            child: _isLoading && _projects.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _projects.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'Tidak ada proyek ditemukan',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Coba dengan kata kunci atau kategori lain',
                              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      )
                    : NotificationListener<ScrollNotification>(
                        onNotification: (scrollInfo) {
                          if (scrollInfo.metrics.pixels == 
                              scrollInfo.metrics.maxScrollExtent) {
                            _loadMore();
                          }
                          return false;
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _projects.length + (_isLoadingMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == _projects.length) {
                              return const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(child: CircularProgressIndicator()),
                              );
                            }
                            final project = _sortedProjects[index];
                            return _buildProjectCard(project);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectCard(ProjectModel project) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProjectDetailPage(projectId: project.id),
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
                  Text(
                    project.formattedBudget,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
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
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: project.statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${project.proposalCount} proposal',
                      style: TextStyle(fontSize: 11, color: project.statusColor),
                    ),
                  ),
                ],
              ),
              if (project.requiredSkills.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Wrap(
                    spacing: 4,
                    children: project.requiredSkills.take(3).map((skill) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.accentColor.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          skill,
                          style: const TextStyle(fontSize: 10),
                        ),
                      );
                    }).toList(),
                  ),
                ),
            ],
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