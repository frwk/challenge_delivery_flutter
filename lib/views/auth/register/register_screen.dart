import 'package:challenge_delivery_flutter/atoms/button_atom.dart';
import 'package:challenge_delivery_flutter/atoms/landing_title_atom.dart';
import 'package:challenge_delivery_flutter/bloc/user/user_bloc.dart';
import 'package:challenge_delivery_flutter/components/input_component.dart';
import 'package:challenge_delivery_flutter/enums/message_type_enum.dart';
import 'package:challenge_delivery_flutter/enums/role_enum.dart';
import 'package:challenge_delivery_flutter/enums/vehicle_enum.dart';
import 'package:challenge_delivery_flutter/helpers/loading_state.dart';
import 'package:challenge_delivery_flutter/helpers/show_snack_message.dart';
import 'package:challenge_delivery_flutter/views/auth/login/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import '../../../atoms/text_button.dart';

class RegisterClientScreen extends StatefulWidget {
  final RoleEnum? role;

  const RegisterClientScreen({super.key, this.role});

  @override
  _RegisterClientScreenState createState() => _RegisterClientScreenState();
}

class _RegisterClientScreenState extends State<RegisterClientScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  late ValueNotifier<String> _roleNotifier;

  @override
  void initState() {
    super.initState();
    _roleNotifier = ValueNotifier<String>(RoleEnum.client.name);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userBloc = BlocProvider.of<UserBloc>(context);

    return BlocListener<UserBloc, UserState>(
      listener: (context, state) {
        if (state is LoadingUserState) {
          modalLoading(context);
        } else if (state is SuccessUserState) {
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
          showSnackMessage(context, 'Inscription réussie', MessageTypeEnum.success);
        } else if (state is FailureUserState) {
          Navigator.of(context, rootNavigator: true).pop();
          showSnackMessage(context, state.error, MessageTypeEnum.error);
        }
      },
      child: Scaffold(
        body: SingleChildScrollView(
          child: FormBuilder(
            key: _formKey,
            child: Column(
              children: [
                ClipRect(
                  child: AspectRatio(
                    aspectRatio: 16 / 4,
                    child: Image.asset(
                      'assets/img/login/login.png',
                      width: double.infinity,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const LandingTitleAtom(title: 'Let\'s', titleColor: Colors.black, subtitle: 'Get Started', subtitleColor: Colors.orangeAccent),
                      const SizedBox(height: 10.0),
                      InputComponent(
                          label: 'Prénom',
                          name: 'firstname',
                          placeholder: 'Votre prénom',
                          displayPlaceholder: true,
                          validators: [FormBuilderValidators.required()]),
                      InputComponent(
                          label: 'Nom',
                          name: 'lastname',
                          placeholder: 'Votre nom',
                          displayPlaceholder: true,
                          validators: [FormBuilderValidators.required()]),
                      InputComponent(
                          label: 'Email',
                          name: 'email',
                          placeholder: 'Votre email',
                          displayPlaceholder: true,
                          validators: [FormBuilderValidators.required(), FormBuilderValidators.email()]),
                      InputComponent(
                          label: 'Mot de passe',
                          name: 'password',
                          placeholder: 'Votre mot de passe',
                          displayPlaceholder: true,
                          obscureText: true,
                          validators: [FormBuilderValidators.required(), FormBuilderValidators.minLength(8, errorText: '8 caractères minimum')]),
                      InputComponent(
                          label: 'Confirmation de mot de passe',
                          name: 'confirm_password',
                          placeholder: 'Confirmer votre mot de passe',
                          displayPlaceholder: true,
                          obscureText: true,
                          validators: [
                            FormBuilderValidators.required(),
                            (value) => _formKey.currentState?.fields['password']?.value != value ? 'Mots de passe différents' : null
                          ]),
                      const SizedBox(height: 20),
                      const Text(
                        'Vous êtes :',
                        style: TextStyle(color: Colors.grey),
                      ),
                      Center(
                        child: SizedBox(
                          width: 200,
                          child: FormBuilderRadioGroup(
                            name: 'role',
                            orientation: OptionsOrientation.horizontal,
                            initialValue: RoleEnum.client.name,
                            options: [
                              FormBuilderFieldOption(value: RoleEnum.client.name, child: const Text('Client')),
                              FormBuilderFieldOption(value: RoleEnum.courier.name, child: const Text('Livreur')),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                _roleNotifier.value = value;
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ValueListenableBuilder(
                        valueListenable: _roleNotifier,
                        builder: (BuildContext context, dynamic value, Widget? child) {
                          if (value == RoleEnum.courier.name) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Quel est le type de votre véhicule ?',
                                  style: TextStyle(color: Colors.grey),
                                ),
                                Center(
                                  child: SizedBox(
                                    width: 300,
                                    child: FormBuilderRadioGroup(
                                      name: 'vehicle',
                                      initialValue: VehicleEnum.car.name,
                                      options: [
                                        FormBuilderFieldOption(value: VehicleEnum.car.name, child: const Text('Voiture')),
                                        FormBuilderFieldOption(value: VehicleEnum.moto.name, child: const Text('Moto')),
                                        FormBuilderFieldOption(value: VehicleEnum.truck.name, child: const Text('Camion')),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          } else {
                            return Container();
                          }
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButtonAtom(
                            label: 'Déjà inscrit ?',
                            labelColor: Colors.grey,
                          ),
                          TextButtonAtom(label: 'Connectez-vous', labelColor: Colors.orangeAccent, redirectTo: '/login'),
                        ],
                      ),
                      ButtonAtom(
                        data: 'S\'inscrire',
                        buttonSize: ButtonSize.large,
                        onTap: () {
                          debugPrint(_formKey.currentState?.instantValue.toString());
                          if (_formKey.currentState!.validate()) {
                            if (_formKey.currentState?.fields['role']?.value == RoleEnum.client.name) {
                              userBloc.add(OnRegisterClientEvent(
                                firstname: _formKey.currentState?.fields['firstname']?.value,
                                lastname: _formKey.currentState?.fields['lastname']?.value,
                                email: _formKey.currentState?.fields['email']?.value,
                                password: _formKey.currentState?.fields['password']?.value,
                              ));
                            } else if (_formKey.currentState?.fields['role']?.value == RoleEnum.courier.name) {
                              userBloc.add(OnRegisterCourierEvent(
                                firstname: _formKey.currentState?.fields['firstname']?.value,
                                lastname: _formKey.currentState?.fields['lastname']?.value,
                                email: _formKey.currentState?.fields['email']?.value,
                                password: _formKey.currentState?.fields['password']?.value,
                                vehicle: _formKey.currentState?.fields['vehicle']?.value,
                              ));
                            }
                          }
                        },
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
