import 'package:challenge_delivery_flutter/bloc/user/user_bloc.dart';
import 'package:challenge_delivery_flutter/enums/message_type_enum.dart';
import 'package:challenge_delivery_flutter/enums/role_enum.dart';
import 'package:challenge_delivery_flutter/helpers/loading_state.dart';
import 'package:challenge_delivery_flutter/helpers/show_snack_message.dart';
import 'package:challenge_delivery_flutter/views/auth/login_screen.dart';
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
        appBar: AppBar(
          leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(alignment: Alignment.center, child: const Text('Annuler', style: TextStyle(color: Colors.white, fontSize: 15))),
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          elevation: 0,
          leadingWidth: 70,
          title: const Text('Créer un compte', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
        body: FormBuilder(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: ListView(
              children: [
                FormBuilderTextField(
                  name: 'firstname',
                  initialValue: 'floflo',
                  decoration: const InputDecoration(labelText: 'Prénom'),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                  ]),
                ),
                const SizedBox(height: 30),
                FormBuilderTextField(
                  name: 'lastname',
                  initialValue: 'peper',
                  decoration: const InputDecoration(labelText: 'Nom de famille'),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                  ]),
                ),
                const SizedBox(height: 30),
                FormBuilderTextField(
                  name: 'email',
                  initialValue: 'floper@gmail.com',
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.email(),
                  ]),
                ),
                const SizedBox(height: 30),
                FormBuilderTextField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  initialValue: 'password123',
                  name: 'password',
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Mot de passe'),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.minLength(8),
                  ]),
                ),
                const SizedBox(height: 30),
                FormBuilderTextField(
                  name: 'confirm_password',
                  initialValue: 'password123',
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: const InputDecoration(labelText: 'Confirmation du mot de passe'),
                  obscureText: true,
                  validator: (value) => _formKey.currentState?.fields['password']?.value != value ? 'Mots de passe différents' : null,
                ),
                const SizedBox(height: 50),
                ElevatedButton(
                  onPressed: () {
                    debugPrint(_formKey.currentState?.instantValue.toString());
                    if (_formKey.currentState!.validate()) {
                      if (widget.role == RoleEnum.client) {
                        userBloc.add(OnRegisterClientEvent(
                          firstname: _formKey.currentState?.fields['firstname']?.value,
                          lastname: _formKey.currentState?.fields['lastname']?.value,
                          email: _formKey.currentState?.fields['email']?.value,
                          password: _formKey.currentState?.fields['password']?.value,
                        ));
                      } else if (widget.role == RoleEnum.courier) {
                        userBloc.add(OnRegisterCourierEvent(
                          firstname: _formKey.currentState?.fields['firstname']?.value,
                          lastname: _formKey.currentState?.fields['lastname']?.value,
                          email: _formKey.currentState?.fields['email']?.value,
                          password: _formKey.currentState?.fields['password']?.value,
                        ));
                      }
                    }
                  },
                  child: const Text('S\'inscrire'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
