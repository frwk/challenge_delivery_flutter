import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:challenge_delivery_flutter/enums/courier_status_enum.dart';
import 'package:challenge_delivery_flutter/enums/role_enum.dart';
import 'package:challenge_delivery_flutter/helpers/secure_storage.dart';
import 'package:challenge_delivery_flutter/models/courier.dart';
import 'package:challenge_delivery_flutter/models/user.dart';
import 'package:challenge_delivery_flutter/services/auth_service.dart';
import 'package:challenge_delivery_flutter/services/location_service.dart';
import 'package:challenge_delivery_flutter/services/notification_service.dart';
import 'package:challenge_delivery_flutter/services/user_service.dart';
import 'package:flutter/material.dart';
part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(const AuthState()) {
    on<LoginEvent>(_onLogin);
    on<CheckLoginEvent>(_onCheckLogin);
    on<LogOutEvent>(_onLogOut);
    on<UpdateProfileEvent>(_onUpdateProfile);
    on<UpdatePasswordEvent>(_onUpdatePassword);
    on<UpdateCourierStatusEvent>(_onUpdateCourierStatus);
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    try {
      emit(LoadingAuthState());
      final user = await authService.login(event.email, event.password);
      await Future.delayed(const Duration(milliseconds: 850));
      User userWithToken = user;
      Courier? courierWithLocation;
      if (user.role == RoleEnum.courier.name && user.courier != null) {
        final location = await LocationService.determineLocation();
        courierWithLocation = user.courier!.copyWith(latitude: location.latitude, longitude: location.longitude);
      }
      final notificationToken = await NotificationService().getToken();
      userWithToken = user.copyWith(courier: () => courierWithLocation, notificationToken: notificationToken);
      await Future.delayed(const Duration(milliseconds: 2000));
      await UserService().updateUser(userWithToken);
      emit(SuccessAuthState(userWithToken));
    } catch (e) {
      emit(FailureAuthState(e.toString()));
    }
  }

  Future<void> _onCheckLogin(CheckLoginEvent event, Emitter<AuthState> emit) async {
    try {
      emit(LoadingAuthState());
      if (await secureStorage.readCookie() != null) {
        final data = await authService.isAuth();
        await Future.delayed(const Duration(milliseconds: 850));
        emit(SuccessAuthState(data));
      } else {
        emit(LogOutAuthState());
      }
    } catch (e) {
      emit(FailureAuthState(e.toString()));
    }
  }

  Future<void> _onLogOut(LogOutEvent event, Emitter<AuthState> emit) async {
    await secureStorage.deleteSecureStorage();
    emit(LogOutAuthState());
  }

  Future<void> _onUpdateProfile(UpdateProfileEvent event, Emitter<AuthState> emit) async {
    try {
      await Future.delayed(const Duration(milliseconds: 850));

      if (state.user == null) {
        throw Exception('User not found');
      }
      final user = state.user!.copyWith(
        firstName: event.firstName,
        lastName: event.lastName,
        email: event.email,
        courier: () => state.user?.role == RoleEnum.courier.name ? state.user!.courier!.copyWith(vehicle: event.vehicle) : null,
      );
      final updatedUser = await UserService().updateUser(user);
      emit(SuccessUpdateProfileState(updatedUser));
    } catch (e) {
      emit(FailureUpdateProfileState(error: e.toString(), user: state.user));
    }
  }

  Future<void> _onUpdatePassword(UpdatePasswordEvent event, Emitter<AuthState> emit) async {
    try {
      emit(LoadingAuthState());
      await Future.delayed(const Duration(milliseconds: 850));
      if (state.user == null) {
        throw Exception('User not found');
      }
      final updatedUser = await UserService().updatePassword(state.user!.id, event.password!);
      emit(SuccessAuthState(updatedUser));
    } catch (e) {
      emit(FailureAuthState(e.toString()));
    }
  }

  Future<void> _onUpdateCourierStatus(UpdateCourierStatusEvent event, Emitter<AuthState> emit) async {
    try {
      await Future.delayed(const Duration(milliseconds: 850));
      if (state.user == null) {
        throw Exception('User not found');
      }
      final updatedCourier = await UserService().updateCourier(state.user!.courier!.copyWith(status: event.status?.name));
      final updatedUser = state.user!.copyWith(courier: () => updatedCourier);
      emit(state.copyWith(user: updatedUser));
    } catch (e) {
      emit(FailureAuthState(e.toString()));
    }
  }
}
