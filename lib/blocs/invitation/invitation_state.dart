part of 'invitation_cubit.dart';

abstract class InvitationState extends Equatable {
  const InvitationState();
  @override
  List<Object?> get props => [];
}

class InvitationInitial extends InvitationState {}

class InvitationLoading extends InvitationState {}

class InvitationsLoaded extends InvitationState {
  final List<InvitationModel> invitations;
  const InvitationsLoaded(this.invitations);
  @override
  List<Object?> get props => [invitations];
}

class InvitationSent extends InvitationState {
  final InvitationModel invitation;
  const InvitationSent(this.invitation);
  @override
  List<Object?> get props => [invitation];
}

class InvitationResponded extends InvitationState {
  final InvitationModel invitation;
  const InvitationResponded(this.invitation);
  @override
  List<Object?> get props => [invitation];
}

class InvitationError extends InvitationState {
  final String message;
  const InvitationError(this.message);
  @override
  List<Object?> get props => [message];
}
