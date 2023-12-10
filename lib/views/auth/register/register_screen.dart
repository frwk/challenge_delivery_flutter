import 'package:challenge_delivery_flutter/atoms/landing_title_atom.dart';
import 'package:challenge_delivery_flutter/bloc/user/user_bloc.dart';
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
                      const SizedBox(height: 20.0),
                      FormBuilderTextField(
                        name: 'firstname',
                        decoration: const InputDecoration(
                            labelText: 'Prénom',
                            labelStyle: TextStyle(
                              color: Colors.grey,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(8.0)),
                              borderSide: BorderSide.none,
                            ),
                            fillColor: Colors.white,
                            filled: true,
                            contentPadding: EdgeInsets.all(15.0)),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                        ]),
                      ),
                      const SizedBox(height: 20.0),
                      FormBuilderTextField(
                        name: 'lastname',
                        decoration: const InputDecoration(
                            labelText: 'Nom',
                            labelStyle: TextStyle(
                              color: Colors.grey,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(8.0)),
                              borderSide: BorderSide.none,
                            ),
                            fillColor: Colors.white,
                            filled: true,
                            contentPadding: EdgeInsets.all(15.0)),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                        ]),
                      ),
                      const SizedBox(height: 20.0),
                      FormBuilderTextField(
                        name: 'email',
                        decoration: const InputDecoration(
                            labelText: 'Email',
                            labelStyle: TextStyle(
                              color: Colors.grey,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(8.0)),
                              borderSide: BorderSide.none,
                            ),
                            fillColor: Colors.white,
                            filled: true,
                            contentPadding: EdgeInsets.all(15.0)),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                          FormBuilderValidators.email(),
                        ]),
                      ),
                      const SizedBox(height: 20.0),
                      FormBuilderTextField(
                        name: 'password',
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        obscureText: true,
                        decoration: const InputDecoration(
                            labelText: 'Mot de passe',
                            labelStyle: TextStyle(
                              color: Colors.grey,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(8.0)),
                              borderSide: BorderSide.none,
                            ),
                            fillColor: Colors.white,
                            filled: true,
                            contentPadding: EdgeInsets.all(15.0)),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                          FormBuilderValidators.minLength(8),
                        ]),
                      ),
                      const SizedBox(height: 20.0),
                      FormBuilderTextField(
                        name: 'confirm_password',
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        obscureText: true,
                        decoration: const InputDecoration(
                            labelText: 'Confirmation de mot de passe',
                            labelStyle: TextStyle(
                              color: Colors.grey,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(8.0)),
                              borderSide: BorderSide.none,
                            ),
                            fillColor: Colors.white,
                            filled: true,
                            contentPadding: EdgeInsets.all(15.0)),
                        validator: (value) => _formKey.currentState?.fields['password']?.value != value ? 'Mots de passe différents' : null,
                      ),
                      const SizedBox(height: 20),
                      const Padding(
                        padding: EdgeInsets.all(5.0),
                        child: Text(
                          'Vous êtes :',
                          style: TextStyle(color: Colors.grey),
                        ),
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
