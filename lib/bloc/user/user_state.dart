part of 'user_bloc.dart';

@immutable
class UserState {
  final User? user;

  const UserState({this.user});

  UserState copyWith({User? user}) => UserState(user: user ?? this.user);
}

class LoadingUserState extends UserState {}

class SuccessUserState extends UserState {}

class FailureUserState extends UserState {
  final String error;

  const FailureUserState(this.error);
}
