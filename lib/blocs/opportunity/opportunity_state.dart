import 'package:equatable/equatable.dart';
import '../../data/models/opportunity_model.dart';

abstract class OpportunityState extends Equatable {
  const OpportunityState();
  @override
  List<Object?> get props => [];
}

class OpportunityInitial extends OpportunityState {}

class OpportunityLoading extends OpportunityState {}

class OpportunityLoaded extends OpportunityState {
  final List<OpportunityModel> opportunities;
  final List<OpportunityModel> featured;
  final List<OpportunityModel> recommended;
  final String searchQuery;
  final String selectedCategory;

  const OpportunityLoaded({
    required this.opportunities,
    this.featured = const [],
    this.recommended = const [],
    this.searchQuery = '',
    this.selectedCategory = 'All Opportunities',
  });

  @override
  List<Object?> get props => [opportunities, featured, recommended, searchQuery, selectedCategory];
}

class OpportunityDetailLoaded extends OpportunityState {
  final OpportunityModel opportunity;
  final bool hasApplied;
  const OpportunityDetailLoaded({required this.opportunity, this.hasApplied = false});
  @override
  List<Object?> get props => [opportunity, hasApplied];
}

class OpportunityError extends OpportunityState {
  final String message;
  const OpportunityError(this.message);
  @override
  List<Object?> get props => [message];
}
