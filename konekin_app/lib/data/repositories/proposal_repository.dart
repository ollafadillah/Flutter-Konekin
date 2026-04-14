import '../datasources/remote/api_service.dart';
import '../models/api_response.dart';
import '../models/proposal_model.dart';

class ProposalRepository {
  final ApiService _apiService = ApiService();
  
  Future<ApiResponse> submitProposal(Map<String, dynamic> proposalData) async {
    return await _apiService.submitProposal(proposalData);
  }
  
  Future<ApiResponse<List<ProposalModel>>> getMyProposals() async {
    return await _apiService.getMyProposals();
  }
  
  Future<ApiResponse<List<ProposalModel>>> getProjectProposals(String projectId) async {
    return await _apiService.getProjectProposals(projectId);
  }
  
  Future<ApiResponse> acceptProposal(String proposalId) async {
    return await _apiService.acceptProposal(proposalId);
  }
  
  Future<ApiResponse> rejectProposal(String proposalId) async {
    return await _apiService.rejectProposal(proposalId);
  }
}