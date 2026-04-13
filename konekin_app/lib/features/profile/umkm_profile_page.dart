import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/helpers.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../auth/login_page.dart';

class UmkmProfilePage extends StatefulWidget {
  const UmkmProfilePage({super.key});

  @override
  State<UmkmProfilePage> createState() => _UmkmProfilePageState();
}

class _UmkmProfilePageState extends State<UmkmProfilePage> {
  final _apiService = ApiService();
  UserModel? _user;
  bool _isLoading = true;
  bool _isEditing = false;
  
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  final _locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    final response = await _apiService.getProfile();
    
    if (mounted) {
      setState(() {
        if (response.success && response.data != null) {
          _user = response.data;
          _updateControllers();
        }
        _isLoading = false;
      });
    }
  }

  void _updateControllers() {
    _nameController.text = _user?.name ?? '';
    _phoneController.text = _user?.phone ?? '';
    _bioController.text = _user?.bio ?? '';
    _locationController.text = _user?.location ?? '';
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    Helpers.showLoadingDialog(context, message: 'Menyimpan...');
    
    final profileData = {
      'name': _nameController.text,
      'phone': _phoneController.text,
      'bio': _bioController.text,
      'location': _locationController.text,
    };
    
    final response = await _apiService.updateProfile(profileData);
    
    if (mounted) {
      Helpers.hideLoadingDialog(context);
      
      if (response.success) {
        setState(() {
          _user = response.data;
          _isEditing = false;
        });
        Helpers.showSuccess(context, 'Profil berhasil diperbarui');
      } else {
        Helpers.showError(context, response.message);
      }
    }
  }

  Future<void> _logout() async {
    final confirm = await Helpers.showConfirmationDialog(
      context,
      title: 'Keluar',
      message: 'Apakah Anda yakin ingin keluar?',
    );
    
    if (confirm) {
      await _apiService.logout();
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.logout();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
        centerTitle: true,
        actions: [
          if (!_isEditing)
            IconButton(
              onPressed: () => setState(() => _isEditing = true),
              icon: const Icon(Icons.edit),
            ),
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _user == null
              ? const Center(child: Text('Gagal memuat profil'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Avatar
                        Center(
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: AppTheme.primaryColor,
                                child: Text(
                                  _user!.name.substring(0, 1).toUpperCase(),
                                  style: const TextStyle(fontSize: 32, color: Colors.white),
                                ),
                              ),
                              if (_isEditing)
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: CircleAvatar(
                                    radius: 16,
                                    backgroundColor: AppTheme.primaryColor,
                                    child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Email (Read-only)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.borderColor),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('EMAIL', style: TextStyle(fontSize: 12, color: Colors.grey)),
                              const SizedBox(height: 4),
                              Text(_user!.email, style: const TextStyle(fontSize: 16)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Name
                        if (_isEditing)
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Nama Lengkap',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                            validator: (value) => value?.isEmpty ?? true ? 'Nama harus diisi' : null,
                          )
                        else
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.borderColor),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('NAMA LENGKAP', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                const SizedBox(height: 4),
                                Text(_user!.name, style: const TextStyle(fontSize: 16)),
                              ],
                            ),
                          ),
                        const SizedBox(height: 16),
                        
                        // Phone
                        if (_isEditing)
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: 'Nomor WhatsApp',
                              prefixIcon: Icon(Icons.phone_outlined),
                            ),
                            validator: (value) {
                              if (value?.isEmpty ?? true) return 'Nomor telepon harus diisi';
                              return null;
                            },
                          )
                        else
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.borderColor),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('NOMOR WHATSAPP', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                const SizedBox(height: 4),
                                Text(_user!.phone, style: const TextStyle(fontSize: 16)),
                              ],
                            ),
                          ),
                        const SizedBox(height: 16),
                        
                        // Location
                        if (_isEditing)
                          TextFormField(
                            controller: _locationController,
                            decoration: const InputDecoration(
                              labelText: 'Lokasi',
                              prefixIcon: Icon(Icons.location_on_outlined),
                            ),
                          )
                        else if (_user!.location != null && _user!.location!.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.borderColor),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('LOKASI', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                const SizedBox(height: 4),
                                Text(_user!.location!, style: const TextStyle(fontSize: 16)),
                              ],
                            ),
                          ),
                        
                        if (_isEditing) const SizedBox(height: 16),
                        
                        // Bio
                        if (_isEditing)
                          TextFormField(
                            controller: _bioController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              labelText: 'Bio / Deskripsi',
                              prefixIcon: Icon(Icons.description_outlined),
                              alignLabelWithHint: true,
                            ),
                          )
                        else if (_user!.bio != null && _user!.bio!.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.borderColor),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('BIO', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                const SizedBox(height: 4),
                                Text(_user!.bio!, style: const TextStyle(fontSize: 14)),
                              ],
                            ),
                          ),
                        
                        const SizedBox(height: 24),
                        
                        if (_isEditing)
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    setState(() {
                                      _isEditing = false;
                                      _updateControllers();
                                    });
                                  },
                                  child: const Text('Batal'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _saveProfile,
                                  child: const Text('Simpan'),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
    );
  }
}