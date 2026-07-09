import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/mock/mock_data.dart';

part 'bookmark_state.dart';

class BookmarkCubit extends Cubit<BookmarkState> {
  final MockDB _db = MockDB();

  BookmarkCubit() : super(BookmarkInitial());

  void load(String userId) {
    try {
      final user = _db.users.firstWhere((u) => u.id == userId);
      emit(BookmarkLoaded(
        savedOpportunityIds: List<String>.from(user.savedOpportunityIds),
        savedStudentIds: List<String>.from(user.savedStudentIds),
      ));
    } catch (_) {
      emit(const BookmarkLoaded(
        savedOpportunityIds: [],
        savedStudentIds: [],
      ));
    }
  }

  void toggleOpportunity(String userId, String opportunityId) {
    _db.toggleSavedOpportunity(userId, opportunityId);
    final current = state;
    if (current is BookmarkLoaded) {
      final ids = List<String>.from(current.savedOpportunityIds);
      ids.contains(opportunityId) ? ids.remove(opportunityId) : ids.add(opportunityId);
      emit(BookmarkLoaded(
        savedOpportunityIds: ids,
        savedStudentIds: current.savedStudentIds,
      ));
    }
  }

  void toggleStudent(String startupId, String studentId) {
    _db.toggleSavedStudent(startupId, studentId);
    final current = state;
    if (current is BookmarkLoaded) {
      final ids = List<String>.from(current.savedStudentIds);
      ids.contains(studentId) ? ids.remove(studentId) : ids.add(studentId);
      emit(BookmarkLoaded(
        savedOpportunityIds: current.savedOpportunityIds,
        savedStudentIds: ids,
      ));
    }
  }

  bool isOpportunitySaved(String opportunityId) {
    final current = state;
    return current is BookmarkLoaded &&
        current.savedOpportunityIds.contains(opportunityId);
  }

  bool isStudentSaved(String studentId) {
    final current = state;
    return current is BookmarkLoaded &&
        current.savedStudentIds.contains(studentId);
  }
}
