import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/invitation_model.dart';
import '../../data/repositories/invitation_repository.dart';

part 'invitation_state.dart';

class InvitationCubit extends Cubit<InvitationState> {
  final InvitationRepository _repo;

  InvitationCubit({required InvitationRepository invitationRepository})
      : _repo = invitationRepository,
        super(InvitationInitial());

  Future<void> loadForStudent(String studentId) async {
    emit(InvitationLoading());
    try {
      final invitations = await _repo.getForStudent(studentId);
      invitations.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      emit(InvitationsLoaded(invitations));
    } catch (e) {
      emit(InvitationError(e.toString()));
    }
  }

  Future<void> loadForStartup(String startupId) async {
    emit(InvitationLoading());
    try {
      final invitations = await _repo.getForStartup(startupId);
      invitations.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      emit(InvitationsLoaded(invitations));
    } catch (e) {
      emit(InvitationError(e.toString()));
    }
  }

  Future<void> send({
    required String startupId,
    required String startupName,
    required String studentId,
    required String studentName,
    required String opportunityId,
    required String roleTitle,
    required String message,
  }) async {
    emit(InvitationLoading());
    try {
      final inv = await _repo.send(
        startupId: startupId,
        startupName: startupName,
        studentId: studentId,
        studentName: studentName,
        opportunityId: opportunityId,
        roleTitle: roleTitle,
        message: message,
      );
      emit(InvitationSent(inv));
    } catch (e) {
      emit(InvitationError(e.toString()));
    }
  }

  Future<void> accept(String invitationId) async {
    try {
      final updated = await _repo.accept(invitationId);
      final current = state;
      if (current is InvitationsLoaded) {
        final list = current.invitations
            .map((i) => i.id == invitationId ? updated : i)
            .toList();
        emit(InvitationsLoaded(list));
      }
      emit(InvitationResponded(updated));
    } catch (e) {
      emit(InvitationError(e.toString()));
    }
  }

  Future<void> decline(String invitationId) async {
    try {
      final updated = await _repo.decline(invitationId);
      final current = state;
      if (current is InvitationsLoaded) {
        final list = current.invitations
            .map((i) => i.id == invitationId ? updated : i)
            .toList();
        emit(InvitationsLoaded(list));
      }
      emit(InvitationResponded(updated));
    } catch (e) {
      emit(InvitationError(e.toString()));
    }
  }
}
