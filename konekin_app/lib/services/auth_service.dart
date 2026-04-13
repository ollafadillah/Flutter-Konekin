import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends ChangeNotifier {
  bool _isLoggedIn = false;
  String _userRole = '';
  String _userId = '';
  String _userName = '';
  
  bool get isLoggedIn => _isLoggedIn;
  String get userRole => _userRole;
  String get userId => _userId;
  String get userName => _userName;

  Future<void> checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.containsKey('auth_token');
    _userRole = prefs.getString('user_role') ?? '';
    _userId = prefs.getString('user_id') ?? '';
    _userName = prefs.getString('user_name') ?? '';
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _isLoggedIn = false;
    _userRole = '';
    _userId = '';
    _userName = '';
    notifyListeners();
  }

  void setAuthData(String token, String role, String userId, String userName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setString('user_role', role);
    await prefs.setString('user_id', userId);
    await prefs.setString('user_name', userName);
    _isLoggedIn = true;
    _userRole = role;
    _userId = userId;
    _userName = userName;
    notifyListeners();
  }
}