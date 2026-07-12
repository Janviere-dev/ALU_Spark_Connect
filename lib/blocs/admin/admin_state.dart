import 'package:equatable/equatable.dart';
import '../../data/models/user_model.dart';

abstract class AdminState extends Equatable {
  const AdminState();
  @override
  List<Object?> get props => [];
}

class AdminInitial extends AdminState {}

class AdminLoading extends AdminState {}

class AdminLoaded extends AdminState {
  final List<UserModel> pending;
  final List<UserModel> approved;
  final List<UserModel> rejected;

  const AdminLoaded({
    required this.pending,
    required this.approved,
    required this.rejected,
  });

  @override
  List<Object?> get props => [pending, approved, rejected];
}

class AdminError extends AdminState {
  final String message;
  const AdminError(this.message);
  @override
  List<Object?> get props => [message];
}

class AdminActionSuccess extends AdminState {
  final String message;
  const AdminActionSuccess(this.message);
  @override
  List<Object?> get props => [message];
}
