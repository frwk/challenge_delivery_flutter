import 'dart:async';
import 'package:challenge_delivery_flutter/models/user.dart';
import 'package:challenge_delivery_flutter/services/user_service.dart';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc() : super(const UserState()) {
    on<OnGetUserEvent>(_onGetUser);
    on<OnRegisterClientEvent>(_onRegisterClient);
    on<OnRegisterCourierEvent>(_onRegisterCourier);
  }

  Future<void> _onGetUser(OnGetUserEvent event, Emitter<UserState> emit) async {
    emit(state.copyWith(user: event.user));
  }

  Future<void> _onRegisterClient(OnRegisterClientEvent event, Emitter<UserState> emit) async {
    try {
      emit(LoadingUserState());
      final data = await userService.registerClient(event.firstname, event.lastname, event.email, event.password);
      emit(SuccessUserState());
    } catch (e) {
      emit(FailureUserState(e.toString()));
    }
  }

  Future<void> _onRegisterCourier(OnRegisterCourierEvent event, Emitter<UserState> emit) async {
    try {
      emit(LoadingUserState());
      final data = await userService.registerCourier(event.firstname, event.lastname, event.email, event.password);
      emit(SuccessUserState());
    } catch (e) {
      emit(FailureUserState(e.toString()));
    }
  }
}
