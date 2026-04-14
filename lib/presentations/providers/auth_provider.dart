import 'package:flutter/material.dart';
import '../../data/models/user_model.dart';
import '../../data/datasources/local/shared_prefs_service.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String _userRole = '';
  String _userId = '';
  String _userName = '';
  
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String get userRole => _userRole;
  String get userId => _userId;
  String get userName => _userName;
  
  Future<void> checkAuthStatus() async {
    _isAuthenticated = SharedPrefsService.containsKey('auth_token');
    _userRole = SharedPrefsService.getString('user_role') ?? '';
    _userId = SharedPrefsService.getString('user_id') ?? '';
    _userName = SharedPrefsService.getString('user_name') ?? '';
    notifyListeners();
  }
  
  Future<void> setMockLogin(String role, String email) async {
    await SharedPrefsService.setString('auth_token', 'mock_token');
    await SharedPrefsService.setString('user_role', role);
    await SharedPrefsService.setString('user_id', 'user_123');
    await SharedPrefsService.setString('user_name', email.split('@')[0]);
    
    _isAuthenticated = true;
    _userRole = role;
    _userId = 'user_123';
    _userName = email.split('@')[0];
    notifyListeners();
  }
  
  // TAMBAHKAN METHOD INI
  Future<bool> updateProfile(Map<String, dynamic> profileData) async {
    _isLoading = true;
    notifyListeners();
    
    // Simulasi update profile
    await Future.delayed(const Duration(seconds: 1));
    
    if (profileData.containsKey('name')) {
      await SharedPrefsService.setString('user_name', profileData['name']);
      _userName = profileData['name'];
    }
    
    _isLoading = false;
    notifyListeners();
    return true;
  }
  
  Future<void> logout() async {
    await SharedPrefsService.clear();
    _isAuthenticated = false;
    _userRole = '';
    _userId = '';
    _userName = '';
    notifyListeners();
  }
}