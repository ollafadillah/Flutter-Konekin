import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/api_constants.dart';
import '../data/models/api_response.dart';
import '../data/models/user_model.dart';
import '../data/models/project_model.dart';
import '../data/models/proposal_model.dart';

class ApiService {
  // ============ PRIVATE METHODS ============
  
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> _get(String url) async {
    final headers = await _getHeaders();
    return await http.get(Uri.parse(url), headers: headers);
  }

  Future<http.Response> _post(String url, dynamic data) async {
    final headers = await _getHeaders();
    return await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(data),
    );
  }

  Future<http.Response> _put(String url, dynamic data) async {
    final headers = await _getHeaders();
    return await http.put(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(data),
    );
  }

  Future<http.Response> _delete(String url) async {
    final headers = await _getHeaders();
    return await http.delete(Uri.parse(url), headers: headers);
  }

  // ============ AUTH ============
  
  Future<ApiResponse<Map<String, dynamic>>> login(String email, String password) async {
    try {
      final response = await _post(ApiConstants.login, {
        'email': email,
        'password': password,
      });
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', data['token']);
        await prefs.setString('user_role', data['user']['role']);
        await prefs.setString('user_id', data['user']['id']);
        await prefs.setString('user_name', data['user']['name']);
        
        return ApiResponse(
          success: true,
          data: data['user'],
          message: 'Login berhasil',
        );
      }
      return ApiResponse(
        success: false,
        message: data['message'] ?? 'Login gagal',
      );
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_role');
      await prefs.remove('user_id');
      await prefs.remove('user_name');
      return ApiResponse(success: true, message: 'Logout berhasil');
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  // ============ PROFILE ============
  
  Future<ApiResponse<UserModel>> getProfile() async {
    try {
      final response = await _get(ApiConstants.getProfile);
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return ApiResponse(
          success: true,
          data: UserModel.fromJson(data['data']),
          message: 'Sukses',
        );
      }
      return ApiResponse(success: false, message: data['message'] ?? 'Gagal memuat profil');
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse<UserModel>> updateProfile(Map<String, dynamic> profileData) async {
    try {
      final response = await _put(ApiConstants.updateProfile, profileData);
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return ApiResponse(
          success: true,
          data: UserModel.fromJson(data['data']),
          message: 'Profil berhasil diperbarui',
        );
      }
      return ApiResponse(success: false, message: data['message'] ?? 'Gagal update profil');
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  // ============ PORTFOLIO ============
  
  Future<ApiResponse<List<Map<String, dynamic>>>> getPortfolios() async {
    try {
      final response = await _get(ApiConstants.getPortfolio);
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        List<Map<String, dynamic>> portfolios = [];
        if (data['data'] is List) {
          portfolios = List<Map<String, dynamic>>.from(data['data']);
        }
        return ApiResponse(
          success: true,
          data: portfolios,
          message: 'Sukses',
        );
      }
      return ApiResponse(success: false, message: data['message'] ?? 'Gagal memuat portfolio');
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> createPortfolio(Map<String, dynamic> portfolioData) async {
    try {
      final response = await _post(ApiConstants.createPortfolio, portfolioData);
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        return ApiResponse(success: true, message: 'Portfolio berhasil ditambahkan');
      }
      return ApiResponse(success: false, message: data['message'] ?? 'Gagal tambah portfolio');
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> deletePortfolio(String portfolioId) async {
    try {
      final response = await _delete('${ApiConstants.deletePortfolio}/$portfolioId');
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return ApiResponse(success: true, message: 'Portfolio berhasil dihapus');
      }
      return ApiResponse(success: false, message: data['message'] ?? 'Gagal hapus portfolio');
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  // ============ PROJECT ============
  
  Future<ApiResponse<ProjectModel>> createProject(Map<String, dynamic> projectData) async {
    try {
      final response = await _post(ApiConstants.createProject, projectData);
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 201) {
        return ApiResponse(
          success: true,
          data: ProjectModel.fromJson(data['data']),
          message: 'Proyek berhasil dibuat',
        );
      }
      return ApiResponse(success: false, message: data['message'] ?? 'Gagal buat proyek');
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse<List<ProjectModel>>> getMyProjects() async {
    try {
      final response = await _get(ApiConstants.getMyProjects);
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        List<ProjectModel> projects = [];
        if (data['data'] is List) {
          projects = (data['data'] as List)
              .map((item) => ProjectModel.fromJson(item))
              .toList();
        }
        return ApiResponse(
          success: true,
          data: projects,
          message: 'Sukses',
        );
      }
      return ApiResponse(success: false, message: data['message'] ?? 'Gagal memuat proyek');
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse<List<ProjectModel>>> getAllProjects({
    String? category,
    String? search,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      String url = ApiConstants.getAllProjects;
      List<String> params = [];
      if (category != null) params.add('category=$category');
      if (search != null) params.add('search=$search');
      params.add('page=$page');
      params.add('limit=$limit');
      if (params.isNotEmpty) url += '?${params.join('&')}';
      
      final response = await _get(url);
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        List<ProjectModel> projects = [];
        if (data['data'] is List) {
          projects = (data['data'] as List)
              .map((item) => ProjectModel.fromJson(item))
              .toList();
        }
        return ApiResponse(
          success: true,
          data: projects,
          message: 'Sukses',
          total: data['total'],
        );
      }
      return ApiResponse(success: false, message: data['message'] ?? 'Gagal memuat proyek');
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse<ProjectModel>> getProjectDetail(String projectId) async {
    try {
      final response = await _get('${ApiConstants.getProjectDetail}/$projectId');
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return ApiResponse(
          success: true,
          data: ProjectModel.fromJson(data['data']),
          message: 'Sukses',
        );
      }
      return ApiResponse(success: false, message: data['message'] ?? 'Gagal memuat detail proyek');
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> deleteProject(String projectId) async {
    try {
      final response = await _delete('${ApiConstants.deleteProject}/$projectId');
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return ApiResponse(success: true, message: 'Proyek berhasil dihapus');
      }
      return ApiResponse(success: false, message: data['message'] ?? 'Gagal hapus proyek');
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  // ============ PROPOSAL ============
  
  Future<ApiResponse> submitProposal(Map<String, dynamic> proposalData) async {
    try {
      final response = await _post(ApiConstants.submitProposal, proposalData);
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 201) {
        return ApiResponse(success: true, message: 'Proposal berhasil dikirim');
      }
      return ApiResponse(success: false, message: data['message'] ?? 'Gagal kirim proposal');
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse<List<ProposalModel>>> getMyProposals() async {
    try {
      final response = await _get(ApiConstants.getMyProposals);
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        List<ProposalModel> proposals = [];
        if (data['data'] is List) {
          proposals = (data['data'] as List)
              .map((item) => ProposalModel.fromJson(item))
              .toList();
        }
        return ApiResponse(
          success: true,
          data: proposals,
          message: 'Sukses',
        );
      }
      return ApiResponse(success: false, message: data['message'] ?? 'Gagal memuat proposal');
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse<List<ProposalModel>>> getProjectProposals(String projectId) async {
    try {
      final response = await _get('${ApiConstants.getProjectProposals}/$projectId');
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        List<ProposalModel> proposals = [];
        if (data['data'] is List) {
          proposals = (data['data'] as List)
              .map((item) => ProposalModel.fromJson(item))
              .toList();
        }
        return ApiResponse(
          success: true,
          data: proposals,
          message: 'Sukses',
        );
      }
      return ApiResponse(success: false, message: data['message'] ?? 'Gagal memuat proposal');
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> acceptProposal(String proposalId) async {
    try {
      final response = await _post('${ApiConstants.acceptProposal}/$proposalId', {});
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return ApiResponse(success: true, message: 'Proposal diterima');
      }
      return ApiResponse(success: false, message: data['message'] ?? 'Gagal menerima proposal');
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> rejectProposal(String proposalId) async {
    try {
      final response = await _post('${ApiConstants.rejectProposal}/$proposalId', {});
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return ApiResponse(success: true, message: 'Proposal ditolak');
      }
      return ApiResponse(success: false, message: data['message'] ?? 'Gagal menolak proposal');
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  // ============ SAVE PROJECT ============
  
  Future<ApiResponse> saveProject(String projectId) async {
    try {
      final response = await _post('${ApiConstants.saveProject}/$projectId', {});
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return ApiResponse(success: true, message: 'Proyek disimpan');
      }
      return ApiResponse(success: false, message: data['message'] ?? 'Gagal menyimpan proyek');
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> unsaveProject(String projectId) async {
    try {
      final response = await _delete('${ApiConstants.unsaveProject}/$projectId');
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return ApiResponse(success: true, message: 'Proyek dihapus dari simpanan');
      }
      return ApiResponse(success: false, message: data['message'] ?? 'Gagal menghapus dari simpanan');
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse<List<ProjectModel>>> getSavedProjects() async {
    try {
      final response = await _get(ApiConstants.getSavedProjects);
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        List<ProjectModel> projects = [];
        if (data['data'] is List) {
          projects = (data['data'] as List)
              .map((item) => ProjectModel.fromJson(item))
              .toList();
        }
        return ApiResponse(
          success: true,
          data: projects,
          message: 'Sukses',
        );
      }
      return ApiResponse(success: false, message: data['message'] ?? 'Gagal memuat proyek tersimpan');
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }
}