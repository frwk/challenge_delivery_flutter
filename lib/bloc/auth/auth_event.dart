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

  UpdateProfileEvent({this.firstName, this.lastName, this.email, this.password});
}

class UpdatePasswordEvent extends AuthEvent {
  final String? password;

  UpdatePasswordEvent({this.password});
}
