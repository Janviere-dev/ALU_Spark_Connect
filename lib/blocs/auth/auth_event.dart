import 'package:equatable/equatable.dart';
import '../../data/models/user_model.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthSignInRequested extends AuthEvent {
  final String email;
  final String password;
  const AuthSignInRequested({required this.email, required this.password});
  @override
  List<Object?> get props => [email, password];
}

class AuthSignUpRequested extends AuthEvent {
  final String fullName;
  final String email;
  final String password;
  final UserRole role;
  final String? ventureName;
  const AuthSignUpRequested({
    required this.fullName,
    required this.email,
    required this.password,
    required this.role,
    this.ventureName,
  });
  @override
  List<Object?> get props => [fullName, email, role, ventureName];
}

class AuthSignOutRequested extends AuthEvent {}

class AuthUserUpdated extends AuthEvent {
  final UserModel user;
  const AuthUserUpdated(this.user);
  @override
  List<Object?> get props => [user];
}
