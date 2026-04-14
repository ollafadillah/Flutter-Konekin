import '../../config/app_config.dart';

class ApiConstants {
  static const String baseUrl = AppConfig.baseUrl;
  static const String uploadUrl = '$baseUrl/upload';
  
  // Auth
  static const String login = '$baseUrl/auth/login';
  static const String register = '$baseUrl/auth/register';
  static const String logout = '$baseUrl/auth/logout';
  static const String checkAuth = '$baseUrl/auth/check';
  
  // User
  static const String getProfile = '$baseUrl/users/profile';
  static const String updateProfile = '$baseUrl/users/profile';
  static const String updatePortfolio = '$baseUrl/users/portfolio';
  
  // Project
  static const String createProject = '$baseUrl/projects';
  static const String getMyProjects = '$baseUrl/projects/my';
  static const String getAllProjects = '$baseUrl/projects';
  static const String getProjectDetail = '$baseUrl/projects';
  static const String updateProject = '$baseUrl/projects';
  static const String deleteProject = '$baseUrl/projects';
  static const String searchProjects = '$baseUrl/projects/search';
  
  // Proposal
  static const String submitProposal = '$baseUrl/proposals';
  static const String getMyProposals = '$baseUrl/proposals/my';
  static const String getProjectProposals = '$baseUrl/proposals/project';
  static const String acceptProposal = '$baseUrl/proposals/accept';
  static const String rejectProposal = '$baseUrl/proposals/reject';
  
  // Save
  static const String saveProject = '$baseUrl/saved';
  static const String getSavedProjects = '$baseUrl/saved';
  static const String unsaveProject = '$baseUrl/saved';
  
  // Portfolio
  static const String getPortfolio = '$baseUrl/users/portfolio';
  static const String createPortfolio = '$baseUrl/users/portfolio';
  static const String deletePortfolio = '$baseUrl/users/portfolio';
}