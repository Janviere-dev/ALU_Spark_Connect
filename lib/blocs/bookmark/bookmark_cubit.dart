import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/repositories/bookmark_repository.dart';

part 'bookmark_state.dart';

class BookmarkCubit extends Cubit<BookmarkState> {
  final BookmarkRepository _repo;

  BookmarkCubit({required BookmarkRepository bookmarkRepository})
      : _repo = bookmarkRepository,
        super(BookmarkInitial());

  Future<void> load(String userId) async {
    try {
      final data = await _repo.load(userId);
      emit(BookmarkLoaded(
        savedOpportunityIds: data['opportunities']!,
        savedStudentIds: data['students']!,
      ));
    } catch (_) {
      emit(const BookmarkLoaded(
        savedOpportunityIds: [],
        savedStudentIds: [],
      ));
    }
  }

  Future<void> toggleOpportunity(String userId, String opportunityId) async {
    final current = state;
    if (current is! BookmarkLoaded) return;
    final isSaved = current.savedOpportunityIds.contains(opportunityId);
    final ids = List<String>.from(current.savedOpportunityIds);
    isSaved ? ids.remove(opportunityId) : ids.add(opportunityId);
    emit(BookmarkLoaded(
      savedOpportunityIds: ids,
      savedStudentIds: current.savedStudentIds,
    ));
    try {
      await _repo.toggleOpportunity(userId, opportunityId, isSaved: isSaved);
    } catch (_) {
      emit(current);
    }
  }

  Future<void> toggleStudent(String startupId, String studentId) async {
    final current = state;
    if (current is! BookmarkLoaded) return;
    final isSaved = current.savedStudentIds.contains(studentId);
    final ids = List<String>.from(current.savedStudentIds);
    isSaved ? ids.remove(studentId) : ids.add(studentId);
    emit(BookmarkLoaded(
      savedOpportunityIds: current.savedOpportunityIds,
      savedStudentIds: ids,
    ));
    try {
      await _repo.toggleStudent(startupId, studentId, isSaved: isSaved);
    } catch (_) {
      emit(current);
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

  List<String> get savedOpportunityIds {
    final current = state;
    return current is BookmarkLoaded ? current.savedOpportunityIds : [];
  }
}
