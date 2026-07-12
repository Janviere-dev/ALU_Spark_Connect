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
  final UserRole? role;
  const AuthSignInRequested({required this.email, required this.password, this.role});
  @override
  List<Object?> get props => [email, password, role];
}

class AuthSignUpRequested extends AuthEvent {
  final String fullName;
  final String email;
  final String password;
  final UserRole role;
  final String? ventureName;
  final String? location;
  final String? docsLink;
  const AuthSignUpRequested({
    required this.fullName,
    required this.email,
    required this.password,
    required this.role,
    this.ventureName,
    this.location,
    this.docsLink,
  });
  @override
  List<Object?> get props => [fullName, email, role, ventureName, location, docsLink];
}

class AuthSignOutRequested extends AuthEvent {}

class AuthUserUpdated extends AuthEvent {
  final UserModel user;
  const AuthUserUpdated(this.user);
  @override
  List<Object?> get props => [user];
}
