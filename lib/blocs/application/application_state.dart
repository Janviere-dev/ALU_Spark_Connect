import 'package:equatable/equatable.dart';
import '../../data/models/application_model.dart';

abstract class ApplicationState extends Equatable {
  const ApplicationState();
  @override
  List<Object?> get props => [];
}

class ApplicationInitial extends ApplicationState {}
class ApplicationLoading extends ApplicationState {}

class ApplicationsLoaded extends ApplicationState {
  final List<ApplicationModel> applications;
  const ApplicationsLoaded(this.applications);
  @override
  List<Object?> get props => [applications];
}

class ApplicationSubmitSuccess extends ApplicationState {
  final ApplicationModel application;
  const ApplicationSubmitSuccess(this.application);
  @override
  List<Object?> get props => [application];
}

class ApplicationError extends ApplicationState {
  final String message;
  const ApplicationError(this.message);
  @override
  List<Object?> get props => [message];
}
