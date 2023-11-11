import 'package:challenge_delivery_flutter/bloc/blocs.dart';
import 'package:challenge_delivery_flutter/bloc/user/user_bloc.dart';
import 'package:challenge_delivery_flutter/enums/message_type_enum.dart';
import 'package:challenge_delivery_flutter/helpers/loading_state.dart';
import 'package:challenge_delivery_flutter/helpers/show_snack_message.dart';
import 'package:challenge_delivery_flutter/views/auth/forgot_password_screen.dart';
import 'package:challenge_delivery_flutter/views/auth/register/register_first_step.dart';
import 'package:challenge_delivery_flutter/widgets/layouts/client_layout.dart';
import 'package:challenge_delivery_flutter/widgets/layouts/courier_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'dart:developer' as developer;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _loginFormKey = GlobalKey<FormBuilderState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final authBloc = BlocProvider.of<AuthBloc>(context);
    final userBloc = BlocProvider.of<UserBloc>(context);

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is LoadingAuthState) {
          modalLoading(context);
        } else if (state is LogOutAuthState) {
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
        } else if (state is FailureAuthState) {
          Navigator.of(context, rootNavigator: true).pop();
          showSnackMessage(context, state.error, MessageTypeEnum.error);
        } else if (state.user?.role != null) {
          developer.log(state.toString(), name: 'ya un role');
          userBloc.add(OnGetUserEvent(state.user!));
          if (state.user?.role == 'client') {
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const ClientLayout()), (route) => false);
          } else if (state.user?.role == 'courier') {
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const CourierLayout()), (route) => false);
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: FormBuilder(
            key: _loginFormKey,
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              children: [
                const SizedBox(height: 20.0),
                Image.asset('assets/logo.png', height: 150),
                const SizedBox(height: 30.0),
                Container(
                  alignment: Alignment.center,
                  child: const Text('Bienvenue!', style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold, color: Color(0xff14222E))),
                ),
                const SizedBox(height: 5.0),
                const Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Utilisez vos identifiants pour vous connecter',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                    maxLines: 2,
                  ),
                ),
                const SizedBox(height: 10.0),
                FormBuilderTextField(
                  name: 'email',
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.email(),
                  ]),
                ),
                const SizedBox(height: 10.0),
                FormBuilderTextField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  name: 'password',
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Mot de passe'),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.minLength(8),
                  ]),
                ),
                const SizedBox(height: 20.0),
                Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordScreen())),
                    child: Text('Mot de passe oublié?', style: TextStyle(fontSize: 17, color: Theme.of(context).colorScheme.primary)),
                  ),
                ),
                const SizedBox(height: 80.0),
                ElevatedButton(
                  child: const Text('Se connecter'),
                  onPressed: () {
                    if (_loginFormKey.currentState!.validate()) {
                      authBloc.add(
                        LoginEvent(
                          _loginFormKey.currentState?.fields['email']?.value,
                          _loginFormKey.currentState?.fields['password']?.value,
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(height: 1, width: 150, color: Colors.grey[300]),
                    const Text('Ou', style: TextStyle(fontSize: 16)),
                    Container(height: 1, width: 150, color: Colors.grey[300])
                  ],
                ),
                const SizedBox(height: 20.0),
                ElevatedButton(
                  child: const Text('S\'inscrire'),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterFirstStep()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
