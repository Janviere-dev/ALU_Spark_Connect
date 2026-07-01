import 'package:equatable/equatable.dart';
import '../../data/models/opportunity_model.dart';
import '../../data/models/user_model.dart';

abstract class StartupState extends Equatable {
  const StartupState();
  @override
  List<Object?> get props => [];
}

class StartupInitial extends StartupState {}
class StartupLoading extends StartupState {}

class StartupDashboardLoaded extends StartupState {
  final int activeRoles;
  final int totalApplications;
  final int avgTimeToHire;
  final int newApplicationsToday;
  final List<OpportunityModel> postings;
  final List<Map<String, String>> recentActivity;

  const StartupDashboardLoaded({
    required this.activeRoles,
    required this.totalApplications,
    required this.avgTimeToHire,
    required this.newApplicationsToday,
    required this.postings,
    required this.recentActivity,
  });

  @override
  List<Object?> get props => [activeRoles, totalApplications, postings, recentActivity];
}

class TalentLoaded extends StartupState {
  final List<UserModel> students;
  final String? skillFilter;
  final String? focusFilter;

  const TalentLoaded({
    required this.students,
    this.skillFilter,
    this.focusFilter,
  });

  @override
  List<Object?> get props => [students, skillFilter, focusFilter];
}

class StartupError extends StartupState {
  final String message;
  const StartupError(this.message);
  @override
  List<Object?> get props => [message];
}

class OpportunityPostSuccess extends StartupState {
  final OpportunityModel opportunity;
  const OpportunityPostSuccess(this.opportunity);
  @override
  List<Object?> get props => [opportunity];
}
