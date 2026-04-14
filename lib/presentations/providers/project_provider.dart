import 'package:flutter/material.dart';
import '../../data/models/project_model.dart';
import '../../data/repositories/project_repository.dart';

class ProjectProvider extends ChangeNotifier {
  final ProjectRepository _projectRepository = ProjectRepository();
  
  List<ProjectModel> _myProjects = [];
  List<ProjectModel> _allProjects = [];
  List<ProjectModel> _savedProjects = [];
  ProjectModel? _currentProject;
  
  bool _isLoading = false;
  String _errorMessage = '';
  int _currentPage = 1;
  int _totalPages = 1;
  
  List<ProjectModel> get myProjects => _myProjects;
  List<ProjectModel> get allProjects => _allProjects;
  List<ProjectModel> get savedProjects => _savedProjects;
  ProjectModel? get currentProject => _currentProject;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get hasMore => _currentPage < _totalPages;
  
  Future<void> loadMyProjects() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    
    final response = await _projectRepository.getMyProjects();
    
    _isLoading = false;
    if (response.success && response.data != null) {
      _myProjects = response.data!;
    } else {
      _errorMessage = response.message;
    }
    notifyListeners();
  }
  
  Future<void> loadAllProjects({
    String? category,
    String? search,
    bool refresh = false,
  }) async {
    if (refresh) {
      _currentPage = 1;
      _allProjects = [];
    }
    
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    
    final response = await _projectRepository.getAllProjects(
      category: category,
      search: search,
      page: _currentPage,
      limit: 10,
    );
    
    _isLoading = false;
    if (response.success && response.data != null) {
      if (refresh) {
        _allProjects = response.data!;
      } else {
        _allProjects.addAll(response.data!);
      }
      _totalPages = (response.total ?? 0) ~/ 10 + 1;
    } else {
      _errorMessage = response.message;
    }
    notifyListeners();
  }
  
  Future<void> loadMoreProjects({String? category, String? search}) async {
    if (!hasMore || _isLoading) return;
    _currentPage++;
    await loadAllProjects(category: category, search: search);
  }
  
  Future<void> loadSavedProjects() async {
    _isLoading = true;
    notifyListeners();
    
    final response = await _projectRepository.getSavedProjects();
    
    _isLoading = false;
    if (response.success && response.data != null) {
      _savedProjects = response.data!;
    }
    notifyListeners();
  }
  
  Future<void> loadProjectDetail(String projectId) async {
    _isLoading = true;
    notifyListeners();
    
    final response = await _projectRepository.getProjectDetail(projectId);
    
    _isLoading = false;
    if (response.success && response.data != null) {
      _currentProject = response.data;
    }
    notifyListeners();
  }
  
  Future<bool> createProject(Map<String, dynamic> projectData) async {
    _isLoading = true;
    notifyListeners();
    
    final response = await _projectRepository.createProject(projectData);
    
    _isLoading = false;
    notifyListeners();
    return response.success;
  }
  
  Future<bool> deleteProject(String projectId) async {
    final response = await _projectRepository.deleteProject(projectId);
    if (response.success) {
      _myProjects.removeWhere((p) => p.id == projectId);
      notifyListeners();
    }
    return response.success;
  }
  
  Future<bool> toggleSaveProject(String projectId, bool isSaved) async {
    final response = isSaved
        ? await _projectRepository.unsaveProject(projectId)
        : await _projectRepository.saveProject(projectId);
    
    if (response.success) {
      if (isSaved) {
        _savedProjects.removeWhere((p) => p.id == projectId);
      } else {
        await loadSavedProjects();
      }
      notifyListeners();
    }
    return response.success;
  }
}