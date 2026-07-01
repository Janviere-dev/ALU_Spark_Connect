import 'package:equatable/equatable.dart';

enum OpportunityStatus { active, paused, closed }

class OpportunityModel extends Equatable {
  final String id;
  final String startupId;
  final String startupName;
  final String? startupLogoUrl;
  final String roleTitle;
  final String category;
  final String description;
  final String? whyJoinUs;
  final List<String> skills;
  final String commitment;
  final String location;
  final String duration;
  final bool isRemoteFriendly;
  final bool equityOffered;
  final String? compensation;
  final int applicantCount;
  final int viewCount;
  final OpportunityStatus status;
  final bool isFeatured;
  final DateTime postedAt;

  const OpportunityModel({
    required this.id,
    required this.startupId,
    required this.startupName,
    this.startupLogoUrl,
    required this.roleTitle,
    required this.category,
    required this.description,
    this.whyJoinUs,
    required this.skills,
    required this.commitment,
    required this.location,
    required this.duration,
    this.isRemoteFriendly = false,
    this.equityOffered = false,
    this.compensation,
    this.applicantCount = 0,
    this.viewCount = 0,
    this.status = OpportunityStatus.active,
    this.isFeatured = false,
    required this.postedAt,
  });

  String get postedTimeAgo {
    final diff = DateTime.now().difference(postedAt);
    if (diff.inDays >= 7) return '${(diff.inDays / 7).floor()}w ago';
    if (diff.inDays >= 1) return '${diff.inDays}d ago';
    if (diff.inHours >= 1) return '${diff.inHours}h ago';
    return 'Just now';
  }

  OpportunityModel copyWith({
    String? roleTitle,
    String? category,
    String? description,
    String? whyJoinUs,
    List<String>? skills,
    String? commitment,
    String? location,
    String? duration,
    bool? isRemoteFriendly,
    bool? equityOffered,
    String? compensation,
    int? applicantCount,
    int? viewCount,
    OpportunityStatus? status,
    bool? isFeatured,
  }) {
    return OpportunityModel(
      id: id,
      startupId: startupId,
      startupName: startupName,
      startupLogoUrl: startupLogoUrl,
      roleTitle: roleTitle ?? this.roleTitle,
      category: category ?? this.category,
      description: description ?? this.description,
      whyJoinUs: whyJoinUs ?? this.whyJoinUs,
      skills: skills ?? this.skills,
      commitment: commitment ?? this.commitment,
      location: location ?? this.location,
      duration: duration ?? this.duration,
      isRemoteFriendly: isRemoteFriendly ?? this.isRemoteFriendly,
      equityOffered: equityOffered ?? this.equityOffered,
      compensation: compensation ?? this.compensation,
      applicantCount: applicantCount ?? this.applicantCount,
      viewCount: viewCount ?? this.viewCount,
      status: status ?? this.status,
      isFeatured: isFeatured ?? this.isFeatured,
      postedAt: postedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        startupId,
        startupName,
        roleTitle,
        category,
        skills,
        commitment,
        location,
        duration,
        status,
        postedAt,
      ];
}
