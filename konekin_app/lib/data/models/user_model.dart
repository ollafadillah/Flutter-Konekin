class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String? bio;
  final String? avatar;
  final String? location;
  final String? experienceLevel;
  final double rating;
  final int completedProjects;
  final List<String> skills;
  final bool isAvailable;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.bio,
    this.avatar,
    this.location,
    this.experienceLevel,
    this.rating = 0,
    this.completedProjects = 0,
    this.skills = const [],
    this.isAvailable = true,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? 'umkm',
      bio: json['bio'],
      avatar: json['avatar'],
      location: json['location'],
      experienceLevel: json['experienceLevel'],
      rating: (json['rating'] ?? 0).toDouble(),
      completedProjects: json['completedProjects'] ?? 0,
      skills: json['skills'] != null ? List<String>.from(json['skills']) : [],
      isAvailable: json['isAvailable'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'bio': bio,
      'avatar': avatar,
      'location': location,
      'experienceLevel': experienceLevel,
      'rating': rating,
      'completedProjects': completedProjects,
      'skills': skills,
      'isAvailable': isAvailable,
    };
  }
}