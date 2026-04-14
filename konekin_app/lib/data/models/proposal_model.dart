import 'package:flutter/material.dart';
import '../../core/utils/helpers.dart';

class ProposalModel {
  final String id;
  final String projectId;
  final String projectTitle;
  final String creativeId;
  final String? creativeName;
  final String? creativeAvatar;
  final double bidAmount;
  final String coverLetter;
  final String? portfolioLink;
  final int estimatedDays;
  final String status;
  final String createdAt;

  ProposalModel({
    required this.id,
    required this.projectId,
    required this.projectTitle,
    required this.creativeId,
    this.creativeName,
    this.creativeAvatar,
    required this.bidAmount,
    required this.coverLetter,
    this.portfolioLink,
    required this.estimatedDays,
    required this.status,
    required this.createdAt,
  });

  factory ProposalModel.fromJson(Map<String, dynamic> json) {
    return ProposalModel(
      id: json['id'] ?? json['_id'] ?? '',
      projectId: json['projectId'] ?? json['project_id'] ?? '',
      projectTitle: json['projectTitle'] ?? json['project_title'] ?? '',
      creativeId: json['creativeId'] ?? json['creative_id'] ?? '',
      creativeName: json['creativeName'] ?? json['creative_name'],
      creativeAvatar: json['creativeAvatar'],
      bidAmount: (json['bidAmount'] ?? json['bid_amount'] ?? 0).toDouble(),
      coverLetter: json['coverLetter'] ?? json['cover_letter'] ?? '',
      portfolioLink: json['portfolioLink'],
      estimatedDays: json['estimatedDays'] ?? json['estimated_days'] ?? 0,
      status: json['status'] ?? 'pending',
      createdAt: json['createdAt'] ?? json['created_at'] ?? '',
    );
  }

  String get formattedBidAmount => Helpers.formatCurrency(bidAmount);
  Color get statusColor => Helpers.getStatusColor(status);
  String get statusText => Helpers.getStatusText(status);
  String get formattedDate => Helpers.formatDate(createdAt);
}