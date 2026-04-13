import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/api_constants.dart';  // <-- TAMBAHKAN INI!
import '../models/api_response.dart';
import '../models/project_model.dart';
import '../models/proposal_model.dart';
import '../models/user_model.dart';

class ApiService {
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<dynamic> _request(String url, {String method = 'GET', dynamic body}) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse(url);
      
      http.Response response;
      
      switch (method) {
        case 'POST':
          response = await http.post(uri, headers: headers, body: jsonEncode(body));
          break;
        case 'PUT':
          response = await http.put(uri, headers: headers, body: jsonEncode(body));
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: headers);
          break;
        default:
          response = await http.get(uri, headers: headers);
      }
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        return {'success': false, 'message': 'Server error: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // AUTH
  Future<ApiResponse<UserModel>> login(String email, String password) async {
    final response = await _request(
      ApiConstants.login,
      method: 'POST',
      body: {'email': email, 'password': password},
    );
    
    if (response['success']) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', response['token']);
      await prefs.setString('user_role', response['user']['role']);
      await prefs.setString('user_id', response['user']['id']);
      
      return ApiResponse(
        success: true,
        message: response['message'],
        data: UserModel.fromJson(response['user']),
      );
    } else {
      return ApiResponse.error(response['message'] ?? 'Login failed');
    }
  }

  Future<ApiResponse<UserModel>> register(Map<String, dynamic> userData) async {
    final response = await _request(
      ApiConstants.register,
      method: 'POST',
      body: userData,
    );
    
    if (response['success']) {
      return ApiResponse(
        success: true,
        message: response['message'],
        data: UserModel.fromJson(response['user']),
      );
    } else {
      return ApiResponse.error(response['message'] ?? 'Registration failed');
    }
  }

  Future<ApiResponse<bool>> logout() async {
    final response = await _request(ApiConstants.logout, method: 'POST');
    if (response['success']) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      return ApiResponse(success: true, message: 'Logout berhasil', data: true);
    }
    return ApiResponse.error(response['message'] ?? 'Logout failed');
  }

  // PROFILE
  Future<ApiResponse<UserModel>> getProfile() async {
    final response = await _request(ApiConstants.getProfile);
    if (response['success']) {
      return ApiResponse(
        success: true,
        message: response['message'],
        data: UserModel.fromJson(response['data']),
      );
    }
    return ApiResponse.error(response['message'] ?? 'Failed to load profile');
  }

  Future<ApiResponse<UserModel>> updateProfile(Map<String, dynamic> profileData) async {
    final response = await _request(
      ApiConstants.updateProfile,
      method: 'PUT',
      body: profileData,
    );
    
    if (response['success']) {
      return ApiResponse(
        success: true,
        message: response['message'],
        data: UserModel.fromJson(response['data']),
      );
    }
    return ApiResponse.error(response['message'] ?? 'Update failed');
  }

  // PROJECTS
  Future<ApiResponseList<ProjectModel>> getMyProjects() async {
    final response = await _request(ApiConstants.getMyProjects);
    if (response['success']) {
      final List<dynamic> data = response['data'];
      final projects = data.map((json) => ProjectModel.fromJson(json)).toList();
      return ApiResponseList(
        success: true,
        message: response['message'],
        data: projects,
        total: response['total'],
      );
    }
    return ApiResponseList(success: false, message: response['message'] ?? 'Failed');
  }

  Future<ApiResponseList<ProjectModel>> getAllProjects({
    String? category,
    String? search,
    int page = 1,
    int limit = 10,
  }) async {
    String url = ApiConstants.getAllProjects;
    final queryParams = <String, String>{};
    if (category != null) queryParams['category'] = category;
    if (search != null) queryParams['search'] = search;
    queryParams['page'] = page.toString();
    queryParams['limit'] = limit.toString();
    
    if (queryParams.isNotEmpty) {
      url = '$url?${Uri(queryParameters: queryParams).query}';
    }
    
    final response = await _request(url);
    if (response['success']) {
      final List<dynamic> data = response['data'];
      final projects = data.map((json) => ProjectModel.fromJson(json)).toList();
      return ApiResponseList(
        success: true,
        message: response['message'],
        data: projects,
        total: response['total'],
        page: response['page'],
        limit: response['limit'],
      );
    }
    return ApiResponseList(success: false, message: response['message'] ?? 'Failed');
  }

  Future<ApiResponse<ProjectModel>> getProjectDetail(String projectId) async {
    final response = await _request('${ApiConstants.getProjectDetail}/$projectId');
    if (response['success']) {
      return ApiResponse(
        success: true,
        message: response['message'],
        data: ProjectModel.fromJson(response['data']),
      );
    }
    return ApiResponse.error(response['message'] ?? 'Project not found');
  }

  Future<ApiResponse<ProjectModel>> createProject(Map<String, dynamic> projectData) async {
    final response = await _request(
      ApiConstants.createProject,
      method: 'POST',
      body: projectData,
    );
    
    if (response['success']) {
      return ApiResponse(
        success: true,
        message: response['message'],
        data: ProjectModel.fromJson(response['data']),
      );
    }
    return ApiResponse.error(response['message'] ?? 'Create failed');
  }

  Future<ApiResponse<bool>> deleteProject(String projectId) async {
    final response = await _request(
      '${ApiConstants.deleteProject}/$projectId',
      method: 'DELETE',
    );
    return ApiResponse(
      success: response['success'],
      message: response['message'],
      data: response['success'],
    );
  }

  // PROPOSALS
  Future<ApiResponse<ProposalModel>> submitProposal(Map<String, dynamic> proposalData) async {
    final response = await _request(
      ApiConstants.submitProposal,
      method: 'POST',
      body: proposalData,
    );
    
    if (response['success']) {
      return ApiResponse(
        success: true,
        message: response['message'],
        data: ProposalModel.fromJson(response['data']),
      );
    }
    return ApiResponse.error(response['message'] ?? 'Submit failed');
  }

  Future<ApiResponseList<ProposalModel>> getMyProposals() async {
    final response = await _request(ApiConstants.getMyProposals);
    if (response['success']) {
      final List<dynamic> data = response['data'];
      final proposals = data.map((json) => ProposalModel.fromJson(json)).toList();
      return ApiResponseList(
        success: true,
        message: response['message'],
        data: proposals,
      );
    }
    return ApiResponseList(success: false, message: response['message'] ?? 'Failed');
  }

  Future<ApiResponseList<ProposalModel>> getProjectProposals(String projectId) async {
    final response = await _request('${ApiConstants.getProjectProposals}/$projectId');
    if (response['success']) {
      final List<dynamic> data = response['data'];
      final proposals = data.map((json) => ProposalModel.fromJson(json)).toList();
      return ApiResponseList(
        success: true,
        message: response['message'],
        data: proposals,
      );
    }
    return ApiResponseList(success: false, message: response['message'] ?? 'Failed');
  }

  Future<ApiResponse<bool>> acceptProposal(String proposalId) async {
    final response = await _request(
      '${ApiConstants.acceptProposal}/$proposalId',
      method: 'PUT',
    );
    return ApiResponse(
      success: response['success'],
      message: response['message'],
      data: response['success'],
    );
  }

  Future<ApiResponse<bool>> rejectProposal(String proposalId) async {
    final response = await _request(
      '${ApiConstants.rejectProposal}/$proposalId',
      method: 'PUT',
    );
    return ApiResponse(
      success: response['success'],
      message: response['message'],
      data: response['success'],
    );
  }

  // SAVED PROJECTS
    // SAVED PROJECTS
  Future<ApiResponse<bool>> saveProject(String projectId) async {
    final response = await _request(
      ApiConstants.saveProject,
      method: 'POST',
      body: {'projectId': projectId},
    );
    return ApiResponse(
      success: response['success'],
      message: response['message'],
      data: response['success'],
    );
  }

  Future<ApiResponse<bool>> unsaveProject(String projectId) async {
    final response = await _request(
      '${ApiConstants.unsaveProject}/$projectId',
      method: 'DELETE',
    );
    return ApiResponse(
      success: response['success'],
      message: response['message'],
      data: response['success'],
    );
  }

  Future<ApiResponseList<ProjectModel>> getSavedProjects() async {
    final response = await _request(ApiConstants.getSavedProjects);
    if (response['success']) {
      final List<dynamic> data = response['data'];
      final projects = data.map((json) => ProjectModel.fromJson(json)).toList();
      return ApiResponseList(
        success: true,
        message: response['message'],
        data: projects,
      );
    }
    return ApiResponseList(success: false, message: response['message'] ?? 'Failed');
  }
}