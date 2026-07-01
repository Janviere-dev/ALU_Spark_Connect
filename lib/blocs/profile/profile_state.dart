import 'package:equatable/equatable.dart';
import '../../data/models/user_model.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();
  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}
class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final UserModel user;
  final List<String> editSkills;
  const ProfileLoaded({required this.user, required this.editSkills});
  @override
  List<Object?> get props => [user, editSkills];
}

class ProfileSaveSuccess extends ProfileState {
  final UserModel user;
  const ProfileSaveSuccess(this.user);
  @override
  List<Object?> get props => [user];
}

class ProfileError extends ProfileState {
  final String message;
  const ProfileError(this.message);
  @override
  List<Object?> get props => [message];
}
