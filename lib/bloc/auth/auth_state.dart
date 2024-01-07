part of 'auth_bloc.dart';

@immutable
class AuthState {
  final User? user;

  const AuthState({this.user});

  AuthState copyWith({User? user}) => AuthState(user: user ?? this.user);
}

class LoadingAuthState extends AuthState {}

class SuccessAuthState extends AuthState {
  const SuccessAuthState(User? user) : super(user: user);
}

class LogOutAuthState extends AuthState {}

class FailureAuthState extends AuthState {
  final error;
  const FailureAuthState(this.error);
}

class FailureUpdateProfileState extends AuthState {
  final error;
  FailureUpdateProfileState({this.error, User? user}) : super(user: user);
}

class SuccessUpdateProfileState extends AuthState {
  const SuccessUpdateProfileState(User? user) : super(user: user);
}
