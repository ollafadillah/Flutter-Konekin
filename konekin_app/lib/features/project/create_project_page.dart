import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/helpers.dart';
import '../../services/api_service.dart';

class CreateProjectPage extends StatefulWidget {
  const CreateProjectPage({super.key});

  @override
  State<CreateProjectPage> createState() => _CreateProjectPageState();
}

class _CreateProjectPageState extends State<CreateProjectPage> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();
  
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _budgetController = TextEditingController();
  final _deadlineController = TextEditingController();
  
  String _selectedCategory = 'Video Editing';
  List<String> _selectedSkills = [];
  final _skillController = TextEditingController();
  bool _isLoading = false;
  
  final List<String> _categories = [
    'Video Editing', 'Graphic Design', 'UI/UX Design', 
    'Web Development', 'Mobile Development', 'Digital Marketing',
    'Content Writing', 'Photography', 'Animation', 'Illustration'
  ];
  
  final List<String> _availableSkills = [
    'Flutter', 'React', 'Node.js', 'UI/UX', 'Figma', 
    'Photoshop', 'Illustrator', 'After Effects', 'Premiere Pro',
    'SEO', 'Content Writing', 'Social Media', 'Python', 'Laravel'
  ];

  Future<void> _selectDeadline() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        _deadlineController.text = date.toIso8601String().split('T')[0];
      });
    }
  }

  void _addSkill(String skill) {
    if (!_selectedSkills.contains(skill)) {
      setState(() {
        _selectedSkills.add(skill);
      });
    }
    _skillController.clear();
  }

  void _removeSkill(String skill) {
    setState(() {
      _selectedSkills.remove(skill);
    });
  }

  Future<void> _handleCreateProject() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    Helpers.showLoadingDialog(context, message: 'Membuat proyek...');
    
    final projectData = {
      'title': _titleController.text,
      'description': _descriptionController.text,
      'category': _selectedCategory,
      'budget': double.parse(_budgetController.text),
      'deadline': _deadlineController.text,
      'requiredSkills': _selectedSkills,
    };
    
    final response = await _apiService.createProject(projectData);
    
    if (mounted) {
      Helpers.hideLoadingDialog(context);
      setState(() => _isLoading = false);
      
      if (response.success) {
        Helpers.showSuccess(context, 'Proyek berhasil dibuat!');
        Navigator.pop(context, true);
      } else {
        Helpers.showError(context, response.message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Proyek Baru'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // INFORMASI DASAR
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'INFORMASI DASAR',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Judul Proyek',
                        hintText: 'Contoh: Membuat Video Promosi',
                      ),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Judul harus diisi' : null,
                    ),
                    const SizedBox(height: 16),
                    
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(labelText: 'Kategori'),
                      items: _categories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => _selectedCategory = value!),
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        labelText: 'Deskripsi Proyek',
                        hintText: 'Jelaskan detail pekerjaan yang dibutuhkan...',
                        alignLabelWithHint: true,
                      ),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Deskripsi harus diisi' : null,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // DETAIL PROYEK
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DETAIL PROYEK',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _budgetController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Budget',
                        prefixText: 'Rp ',
                      ),
                      validator: (value) {
                        if (value?.isEmpty ?? true) return 'Budget harus diisi';
                        if (double.tryParse(value!) == null) return 'Budget harus angka';
                        if (double.parse(value) <= 0) return 'Budget harus lebih dari 0';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _deadlineController,
                      readOnly: true,
                      onTap: _selectDeadline,
                      decoration: InputDecoration(
                        labelText: 'Deadline',
                        suffixIcon: const Icon(Icons.calendar_today),
                      ),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Deadline harus diisi' : null,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // KEAHLIAN YANG DIBUTUHKAN
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'KEAHLIAN YANG DIBUTUHKAN',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Selected Skills
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ..._selectedSkills.map((skill) => Chip(
                          label: Text(skill),
                          onDeleted: () => _removeSkill(skill),
                          deleteIcon: const Icon(Icons.close, size: 16),
                        )),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Add Skill
                    Row(
                      children: [
                        Expanded(
                          child: Autocomplete<String>(
                            optionsBuilder: (textEditingValue) {
                              if (textEditingValue.text.isEmpty) {
                                return const Iterable<String>.empty();
                              }
                              return _availableSkills.where((skill) =>
                                  skill.toLowerCase().contains(
                                    textEditingValue.text.toLowerCase(),
                                  ));
                            },
                            onSelected: (selection) {
                              _addSkill(selection);
                            },
                            fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                              _skillController.addListener(() {
                                controller.text = _skillController.text;
                              });
                              return TextField(
                                controller: controller,
                                focusNode: focusNode,
                                decoration: const InputDecoration(
                                  labelText: 'Tambah Keahlian',
                                  hintText: 'Cari keahlian...',
                                  suffixIcon: Icon(Icons.add),
                                ),
                                onSubmitted: (value) {
                                  if (value.isNotEmpty) {
                                    _addSkill(value);
                                  }
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              ElevatedButton(
                onPressed: _isLoading ? null : _handleCreateProject,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Posting Proyek'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}