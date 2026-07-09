part of 'bookmark_cubit.dart';

abstract class BookmarkState extends Equatable {
  const BookmarkState();
  @override
  List<Object?> get props => [];
}

class BookmarkInitial extends BookmarkState {}

class BookmarkLoaded extends BookmarkState {
  final List<String> savedOpportunityIds;
  final List<String> savedStudentIds;

  const BookmarkLoaded({
    required this.savedOpportunityIds,
    required this.savedStudentIds,
  });

  @override
  List<Object?> get props => [savedOpportunityIds, savedStudentIds];
}
