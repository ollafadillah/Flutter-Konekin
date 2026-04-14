import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/helpers.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../auth/login_page.dart';

class CreativeProfilePage extends StatefulWidget {
  const CreativeProfilePage({super.key});

  @override
  State<CreativeProfilePage> createState() => _CreativeProfilePageState();
}

class _CreativeProfilePageState extends State<CreativeProfilePage> {
  final _apiService = ApiService();
  UserModel? _user;
  bool _isLoading = true;
  bool _isEditing = false;
  
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  final _locationController = TextEditingController();
  
  String _selectedExperience = 'Menengah';
  final List<String> _experienceLevels = ['Pemula', 'Menengah', 'Ahli'];
  
  List<String> _skills = [];
  final _skillController = TextEditingController();
  bool _isAvailable = true;

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
    _skillController.dispose();
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
    _selectedExperience = _user?.experienceLevel ?? 'Menengah';
    _skills = _user?.skills ?? [];
    _isAvailable = _user?.isAvailable ?? true;
  }

  void _addSkill() {
    if (_skillController.text.isNotEmpty && !_skills.contains(_skillController.text)) {
      setState(() {
        _skills.add(_skillController.text);
        _skillController.clear();
      });
    }
  }

  void _removeSkill(String skill) {
    setState(() {
      _skills.remove(skill);
    });
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    Helpers.showLoadingDialog(context, message: 'Menyimpan...');
    
    final profileData = {
      'name': _nameController.text,
      'phone': _phoneController.text,
      'bio': _bioController.text,
      'location': _locationController.text,
      'experienceLevel': _selectedExperience,
      'skills': _skills,
      'isAvailable': _isAvailable,
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
                        // Header Card with Stats
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 35,
                                    backgroundColor: Colors.white,
                                    child: Text(
                                      _user!.name.substring(0, 1).toUpperCase(),
                                      style: TextStyle(fontSize: 28, color: AppTheme.primaryColor),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _user!.name,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            _selectedExperience,
                                            style: const TextStyle(fontSize: 12, color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.star, size: 16, color: Colors.amber),
                                          const SizedBox(width: 4),
                                          Text(
                                            _user!.rating.toStringAsFixed(1),
                                            style: const TextStyle(color: Colors.white),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${_user!.completedProjects} proyek',
                                        style: const TextStyle(fontSize: 12, color: Colors.white70),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Availability Badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _isAvailable ? Colors.green : Colors.grey,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _isAvailable ? Icons.check_circle : Icons.cancel,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _isAvailable ? 'Tersedia' : 'Tidak Tersedia',
                                      style: const TextStyle(fontSize: 12, color: Colors.white),
                                    ),
                                  ],
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
                        
                        // Edit Mode Form
                        if (_isEditing) ...[
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Nama Lengkap',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                            validator: (value) => value?.isEmpty ?? true ? 'Nama harus diisi' : null,
                          ),
                          const SizedBox(height: 16),
                          
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
                          ),
                          const SizedBox(height: 16),
                          
                          TextFormField(
                            controller: _locationController,
                            decoration: const InputDecoration(
                              labelText: 'Lokasi',
                              prefixIcon: Icon(Icons.location_on_outlined),
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          DropdownButtonFormField<String>(
                            initialValue: _selectedExperience,
                            decoration: const InputDecoration(
                              labelText: 'Tingkat Pengalaman',
                              prefixIcon: Icon(Icons.trending_up),
                            ),
                            items: _experienceLevels.map((level) {
                              return DropdownMenuItem(value: level, child: Text(level));
                            }).toList(),
                            onChanged: (value) => setState(() => _selectedExperience = value!),
                          ),
                          const SizedBox(height: 16),
                          
                          // Skills
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Keahlian', style: TextStyle(fontWeight: FontWeight.w500)),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  ..._skills.map((skill) => Chip(
                                    label: Text(skill),
                                    onDeleted: () => _removeSkill(skill),
                                    deleteIcon: const Icon(Icons.close, size: 16),
                                  )),
                                  ActionChip(
                                    label: const Text('+ Tambah'),
                                    onPressed: () => _showAddSkillDialog(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          TextFormField(
                            controller: _bioController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              labelText: 'Bio / Deskripsi',
                              prefixIcon: Icon(Icons.description_outlined),
                              alignLabelWithHint: true,
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          SwitchListTile(
                            title: const Text('Status Tersedia'),
                            subtitle: const Text('Aktifkan agar UMKM dapat melihat Anda'),
                            value: _isAvailable,
                            onChanged: (value) => setState(() => _isAvailable = value),
                            activeThumbColor: AppTheme.primaryColor,
                            contentPadding: EdgeInsets.zero,
                          ),
                          const SizedBox(height: 24),
                          
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
                        ] else ...[
                          // Info Kontak
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
                                const Text('INFORMASI KONTAK', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Icon(Icons.phone, size: 16, color: Colors.grey),
                                    const SizedBox(width: 8),
                                    Text(_user!.phone),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                if (_user!.location != null && _user!.location!.isNotEmpty)
                                  Row(
                                    children: [
                                      Icon(Icons.location_on, size: 16, color: Colors.grey),
                                      const SizedBox(width: 8),
                                      Text(_user!.location!),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Skills
                          if (_skills.isNotEmpty)
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
                                  const Text('KEAHLIAN', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: _skills.map((skill) => Chip(label: Text(skill))).toList(),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 16),
                          
                          // Bio
                          if (_user!.bio != null && _user!.bio!.isNotEmpty)
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
                                  const Text('TENTANG SAYA', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                  const SizedBox(height: 8),
                                  Text(_user!.bio!, style: const TextStyle(fontSize: 14)),
                                ],
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                ),
    );
  }

  void _showAddSkillDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Keahlian'),
        content: TextField(
          controller: _skillController,
          decoration: const InputDecoration(
            hintText: 'Contoh: UI/UX Design, Flutter, dll',
          ),
          onSubmitted: (_) {
            _addSkill();
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              _addSkill();
              Navigator.pop(context);
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }
}