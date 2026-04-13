import 'package:flutter/material.dart';
import '../core/utils/helpers.dart';

class ProjectModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final double budget;
  final String deadline;
  final String status;
  final String clientId;
  final String? clientName;
  final String? clientAvatar;
  final String createdAt;
  final String? selectedCreativeId;
  final List<String> requiredSkills;
  final int proposalCount;
  final bool isSaved;

  ProjectModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.budget,
    required this.deadline,
    required this.status,
    required this.clientId,
    this.clientName,
    this.clientAvatar,
    required this.createdAt,
    this.selectedCreativeId,
    this.requiredSkills = const [],
    this.proposalCount = 0,
    this.isSaved = false,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] ?? json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      budget: (json['budget'] ?? 0).toDouble(),
      deadline: json['deadline'] ?? '',
      status: json['status'] ?? 'open',
      clientId: json['clientId'] ?? json['client_id'] ?? '',
      clientName: json['clientName'] ?? json['client_name'],
      clientAvatar: json['clientAvatar'],
      createdAt: json['createdAt'] ?? json['created_at'] ?? '',
      selectedCreativeId: json['selectedCreativeId'],
      requiredSkills: json['requiredSkills'] != null 
          ? List<String>.from(json['requiredSkills']) 
          : [],
      proposalCount: json['proposalCount'] ?? 0,
      isSaved: json['isSaved'] ?? false,
    );
  }

  String get formattedBudget => Helpers.formatCurrency(budget);
  Color get statusColor => Helpers.getStatusColor(status);
  String get statusText => Helpers.getStatusText(status);
  int get daysRemaining => Helpers.getDaysRemaining(deadline);
  String get formattedDate => Helpers.formatDate(createdAt);
  String get formattedDeadline => Helpers.formatDate(deadline);
}