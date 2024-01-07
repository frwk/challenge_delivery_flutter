part of 'user_bloc.dart';

@immutable
abstract class UserEvent {}

class OnGetUserEvent extends UserEvent {
  final User user;

  OnGetUserEvent(this.user);
}

class OnEditUserEvent extends UserEvent {
  final String name;
  final String lastname;

  OnEditUserEvent(this.name, this.lastname);
}

class OnChangePasswordEvent extends UserEvent {
  final String currentPassword;
  final String newPassword;

  OnChangePasswordEvent(this.currentPassword, this.newPassword);
}

class OnRegisterCourierEvent extends UserEvent {
  final String firstname;
  final String lastname;
  final String email;
  final String password;
  final String vehicle;

  OnRegisterCourierEvent({required this.firstname, required this.lastname, required this.email, required this.password, required this.vehicle});
}

class OnRegisterClientEvent extends UserEvent {
  final String firstname;
  final String lastname;
  final String email;
  final String password;

  OnRegisterClientEvent({required this.firstname, required this.lastname, required this.email, required this.password});
}

class OnDeleteStreetAddressEvent extends UserEvent {
  final int uid;

  OnDeleteStreetAddressEvent(this.uid);
}

class OnAddNewAddressEvent extends UserEvent {
  final String street;
  final String reference;
  final LatLng location;

  OnAddNewAddressEvent(this.street, this.reference, this.location);
}

class OnSelectAddressButtonEvent extends UserEvent {
  final int uidAddress;
  final String addressName;

  OnSelectAddressButtonEvent(this.uidAddress, this.addressName);
}

class OnUpdateDeliveryToClientEvent extends UserEvent {
  final String idPerson;

  OnUpdateDeliveryToClientEvent(this.idPerson);
}
