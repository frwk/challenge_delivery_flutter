part of 'auth_bloc.dart';

@immutable
abstract class AuthEvent {}

class InitialAuthEvent extends AuthEvent {}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  LoginEvent(this.email, this.password);
}

class CheckLoginEvent extends AuthEvent {}

class LogOutEvent extends AuthEvent {}

class UpdateProfileEvent extends AuthEvent {
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? password;
  final String? vehicle;

  UpdateProfileEvent({this.firstName, this.lastName, this.email, this.password, this.vehicle});
}

class UpdatePasswordEvent extends AuthEvent {
  final String? password;

  UpdatePasswordEvent({this.password});
}

class UpdateCourierStatusEvent extends AuthEvent {
  final CourierStatusEnum? status;

  UpdateCourierStatusEvent({this.status});
}
