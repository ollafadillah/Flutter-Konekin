import 'package:flutter/material.dart';
import '../../data/models/proposal_model.dart';
import '../../data/repositories/proposal_repository.dart';

class ProposalProvider extends ChangeNotifier {
  final ProposalRepository _proposalRepository = ProposalRepository();
  
  List<ProposalModel> _myProposals = [];
  List<ProposalModel> _projectProposals = [];
  bool _isLoading = false;
  String _errorMessage = '';
  
  List<ProposalModel> get myProposals => _myProposals;
  List<ProposalModel> get projectProposals => _projectProposals;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  
  Future<void> loadMyProposals() async {
    _isLoading = true;
    notifyListeners();
    
    final response = await _proposalRepository.getMyProposals();
    
    _isLoading = false;
    if (response.success && response.data != null) {
      _myProposals = response.data!;
    } else {
      _errorMessage = response.message;
    }
    notifyListeners();
  }
  
  Future<void> loadProjectProposals(String projectId) async {
    _isLoading = true;
    notifyListeners();
    
    final response = await _proposalRepository.getProjectProposals(projectId);
    
    _isLoading = false;
    if (response.success && response.data != null) {
      _projectProposals = response.data!;
    }
    notifyListeners();
  }
  
  Future<bool> submitProposal(Map<String, dynamic> proposalData) async {
    _isLoading = true;
    notifyListeners();
    
    final response = await _proposalRepository.submitProposal(proposalData);
    
    _isLoading = false;
    notifyListeners();
    return response.success;
  }
  
  Future<bool> acceptProposal(String proposalId) async {
    final response = await _proposalRepository.acceptProposal(proposalId);
    if (response.success) {
      await loadProjectProposals(_projectProposals.first.projectId);
    }
    return response.success;
  }
  
  Future<bool> rejectProposal(String proposalId) async {
    final response = await _proposalRepository.rejectProposal(proposalId);
    if (response.success) {
      await loadProjectProposals(_projectProposals.first.projectId);
    }
    return response.success;
  }
}