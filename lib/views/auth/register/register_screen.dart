import 'package:challenge_delivery_flutter/atoms/landing_title_atom.dart';
import 'package:challenge_delivery_flutter/bloc/user/user_bloc.dart';
import 'package:challenge_delivery_flutter/components/input_component.dart';
import 'package:challenge_delivery_flutter/enums/message_type_enum.dart';
import 'package:challenge_delivery_flutter/enums/role_enum.dart';
import 'package:challenge_delivery_flutter/helpers/loading_state.dart';
import 'package:challenge_delivery_flutter/helpers/show_snack_message.dart';
import 'package:challenge_delivery_flutter/views/auth/login/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'dart:developer' as developer;

import '../../../atoms/text_button.dart';

class RegisterClientScreen extends StatefulWidget {
  final RoleEnum? role;

  const RegisterClientScreen({Key? key, this.role}) : super(key: key);

  @override
  _RegisterClientScreenState createState() => _RegisterClientScreenState();
}

class _RegisterClientScreenState extends State<RegisterClientScreen> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  void initState() {
    super.initState();
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
        developer.log(state.toString(), name: 'AUTHSTATE IN REGISTER');
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
                      InputComponent(label: 'Prénom', name: 'firstname', placeholder: 'Votre prénom', displayPlaceholder: true, validators: [FormBuilderValidators.required()]),
                      InputComponent(label: 'Nom', name: 'lastname', placeholder: 'Votre nom', displayPlaceholder: true, validators: [FormBuilderValidators.required()]),
                      InputComponent(label: 'Email', name:'email', placeholder: 'Votre email', displayPlaceholder: true, validators: [FormBuilderValidators.required(),  FormBuilderValidators.email()]),
                      InputComponent(label: 'Mot de passe', name: 'password' ,placeholder: 'Votre mot de passe', displayPlaceholder: true, password: true, validators: [FormBuilderValidators.required(), FormBuilderValidators.minLength(8)]),
                      InputComponent(label: 'Confirmation de mot de passe', name:'confirm_password', placeholder: 'Confirmer votre mot de passe', displayPlaceholder: true, password: true, validators: [FormBuilderValidators.required(), (value) => _formKey.currentState?.fields['password']?.value != value ? 'Mots de passe différents' : null]),
                      const SizedBox(height: 5),
                      const Text(
                        'Vous êtes :',
                        style: TextStyle(color: Colors.grey),
                      ),
                      Center(
                        child: Container(
                          width: 200,
                          child: FormBuilderRadioGroup(
                            name: 'role',
                            orientation: OptionsOrientation.horizontal,
                            initialValue: RoleEnum.client.name,
                            options: [
                              FormBuilderFieldOption(value: RoleEnum.client.name, child: const Text('Client')),
                              FormBuilderFieldOption(value: RoleEnum.courier.name, child: const Text('Livreur')),
                            ],
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButtonAtom(label: 'Déjà inscrit ?', labelColor: Colors.grey,),
                          TextButtonAtom(label: 'Connectez-vous', labelColor: Colors.orangeAccent, redirectTo: '/login'),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {
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
                              ));
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orangeAccent[200],
                          fixedSize: const Size(400, 50),
                        ),
                        child: const Text('S\'inscrire'),
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
