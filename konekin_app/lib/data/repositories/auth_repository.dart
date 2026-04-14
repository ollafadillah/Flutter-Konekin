import '../datasources/remote/api_service.dart';
import '../models/api_response.dart';
import '../models/user_model.dart';

class AuthRepository {
  final ApiService _apiService = ApiService();
  
  Future<ApiResponse<Map<String, dynamic>>> login(String email, String password) async {
    return await _apiService.login(email, password);
  }
  
  Future<ApiResponse> logout() async {
    return await _apiService.logout();
  }
  
  Future<ApiResponse<UserModel>> getProfile() async {
    return await _apiService.getProfile();
  }
  
  Future<ApiResponse<UserModel>> updateProfile(Map<String, dynamic> profileData) async {
    return await _apiService.updateProfile(profileData);
  }
}