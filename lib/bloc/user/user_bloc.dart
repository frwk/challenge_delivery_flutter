import 'dart:async';
import 'package:challenge_delivery_flutter/enums/role_enum.dart';
import 'package:challenge_delivery_flutter/models/courier.dart';
import 'package:challenge_delivery_flutter/models/user.dart';
import 'package:challenge_delivery_flutter/services/location_service.dart';
import 'package:challenge_delivery_flutter/services/notification_service.dart';
import 'package:challenge_delivery_flutter/services/user_service.dart';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc() : super(const UserState()) {
    on<OnGetUserEvent>(_onGetUser);
    on<OnRegisterClientEvent>(_onRegisterClient);
    on<OnRegisterCourierEvent>(_onRegisterCourier);
  }

  Future<void> _onGetUser(OnGetUserEvent event, Emitter<UserState> emit) async {
    try {
      User userWithToken = event.user;
      if (event.user.role == RoleEnum.courier.name) {
        final location = await LocationService.determineLocation();
        userWithToken = event.user.copyWith(courier: event.user.courier!.copyWith(latitude: location.latitude, longitude: location.longitude));
      }
      if ((event.user.notificationToken ?? '').isEmpty) {
        userWithToken = event.user.copyWith(notificationToken: await NotificationService().getToken());
      }
      final data = await UserService().updateUser(userWithToken);
      emit(state.copyWith(user: userWithToken));
    } catch (e) {
      emit(FailureUserState(e.toString()));
    }
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
