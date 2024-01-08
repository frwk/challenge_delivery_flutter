import 'package:challenge_delivery_flutter/atoms/button_atom.dart';
import 'package:challenge_delivery_flutter/bloc/auth/auth_bloc.dart';
import 'package:challenge_delivery_flutter/components/input_component.dart';
import 'package:challenge_delivery_flutter/enums/message_type_enum.dart';
import 'package:challenge_delivery_flutter/enums/role_enum.dart';
import 'package:challenge_delivery_flutter/enums/vehicle_enum.dart';
import 'package:challenge_delivery_flutter/helpers/show_snack_message.dart';
import 'package:challenge_delivery_flutter/widgets/layouts/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'dart:developer' as developer;

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  String _firstName = '';
  String _lastName = '';
  String _email = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authUser = BlocProvider.of<AuthBloc>(context).state.user;
    _firstName = authUser!.firstName;
    _lastName = authUser.lastName;
    _email = authUser.email;
  }

  @override
  Widget build(BuildContext context) {
    final authBloc = BlocProvider.of<AuthBloc>(context);
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is FailureUpdateProfileState) {
          showSnackMessage(context, state.error, MessageTypeEnum.error);
        } else if (state is SuccessUpdateProfileState) {
          showSnackMessage(context, 'Profil mis à jour avec succès', MessageTypeEnum.success);
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: const MyAppBar(title: 'Modifier le profil'),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(20),
            child: FormBuilder(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  InputComponent(
                    name: 'firstName',
                    placeholder: 'Prénom',
                    displayPlaceholder: true,
                    initialValue: _firstName,
                    validators: [
                      FormBuilderValidators.required(),
                    ],
                  ),
                  InputComponent(
                    name: 'lastName',
                    placeholder: 'Nom de famille',
                    displayPlaceholder: true,
                    initialValue: _lastName,
                    validators: [
                      FormBuilderValidators.required(),
                    ],
                  ),
                  InputComponent(
                    name: 'email',
                    placeholder: 'Email',
                    displayPlaceholder: true,
                    initialValue: _email,
                    validators: [
                      FormBuilderValidators.required(),
                      FormBuilderValidators.email(),
                    ],
                  ),
                  const SizedBox(height: 30),
                  if (authBloc.state.user?.role == RoleEnum.courier.name) ...[
                    Container(
                      width: MediaQuery.of(context).size.width * 0.75,
                      child: const Divider(
                        thickness: 1,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: FormBuilderRadioGroup(
                        name: 'vehicle',
                        decoration: const InputDecoration(labelText: 'Type de véhicule', border: InputBorder.none),
                        initialValue: authBloc.state.user?.courier?.vehicle,
                        options: [
                          FormBuilderFieldOption(value: VehicleEnum.car.name, child: const Text('Voiture')),
                          FormBuilderFieldOption(value: VehicleEnum.moto.name, child: const Text('Moto')),
                          FormBuilderFieldOption(value: VehicleEnum.truck.name, child: const Text('Camion')),
                        ],
                      ),
                    ),
                  ],
                  ButtonAtom(
                    data: 'Enregistrer les modifications',
                    onTap: () {
                      if (_formKey.currentState!.saveAndValidate()) {
                        try {
                          developer.log(_formKey.currentState!.fields['firstName']?.value, name: 'EditProfileScreen');
                          authBloc.add(UpdateProfileEvent(
                            firstName: _formKey.currentState!.fields['firstName']?.value,
                            lastName: _formKey.currentState!.fields['lastName']?.value,
                            email: _formKey.currentState!.fields['email']?.value,
                            vehicle: authBloc.state.user?.role == RoleEnum.courier.name ? _formKey.currentState!.fields['vehicle']?.value : null,
                          ));
                        } catch (e) {
                          print(e);
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
