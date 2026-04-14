import '../datasources/remote/api_service.dart';
import '../models/api_response.dart';
import '../models/project_model.dart';

class ProjectRepository {
  final ApiService _apiService = ApiService();
  
  Future<ApiResponse<ProjectModel>> createProject(Map<String, dynamic> projectData) async {
    return await _apiService.createProject(projectData);
  }
  
  Future<ApiResponse<List<ProjectModel>>> getMyProjects() async {
    return await _apiService.getMyProjects();
  }
  
  Future<ApiResponse<List<ProjectModel>>> getAllProjects({
    String? category,
    String? search,
    int page = 1,
    int limit = 10,
  }) async {
    return await _apiService.getAllProjects(
      category: category,
      search: search,
      page: page,
      limit: limit,
    );
  }
  
  Future<ApiResponse<ProjectModel>> getProjectDetail(String projectId) async {
    return await _apiService.getProjectDetail(projectId);
  }
  
  Future<ApiResponse> deleteProject(String projectId) async {
    return await _apiService.deleteProject(projectId);
  }
  
  Future<ApiResponse> saveProject(String projectId) async {
    return await _apiService.saveProject(projectId);
  }
  
  Future<ApiResponse> unsaveProject(String projectId) async {
    return await _apiService.unsaveProject(projectId);
  }
  
  Future<ApiResponse<List<ProjectModel>>> getSavedProjects() async {
    return await _apiService.getSavedProjects();
  }
}