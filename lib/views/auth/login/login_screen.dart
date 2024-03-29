import 'package:challenge_delivery_flutter/bloc/auth/auth_bloc.dart';
import 'package:challenge_delivery_flutter/bloc/user/user_bloc.dart';
import 'package:challenge_delivery_flutter/components/input_component.dart';
import 'package:challenge_delivery_flutter/enums/message_type_enum.dart';
import 'package:challenge_delivery_flutter/helpers/loading_state.dart';
import 'package:challenge_delivery_flutter/helpers/show_snack_message.dart';
import 'package:challenge_delivery_flutter/views/auth/forgot_password_screen.dart';
import 'package:challenge_delivery_flutter/widgets/layouts/client_layout.dart';
import 'package:challenge_delivery_flutter/widgets/layouts/courier_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import '../../../atoms/landing_title_atom.dart';
import '../../../atoms/text_button.dart';

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

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is LoadingAuthState) {
          modalLoading(context);
        } else if (state is LogOutAuthState) {
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
        } else if (state is FailureAuthState) {
          Navigator.of(context, rootNavigator: true).pop();
          showSnackMessage(context, state.error, MessageTypeEnum.error);
        } else if (state is SuccessAuthState && state.user?.role != null) {
          if (state.user?.role == 'client') {
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const ClientLayout()), (route) => false);
          } else if (state.user?.role == 'courier') {
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const CourierLayout()), (route) => false);
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: SingleChildScrollView(
          child: FormBuilder(
              key: _loginFormKey,
              child: Column(
                children: [
                  if (MediaQuery.of(context).size.width < 600) Image.asset('assets/img/login/login.png'),
                  Padding(
                    padding: const EdgeInsets.only(top: 42.0, left: 22.0, right: 22.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const LandingTitleAtom(title: 'Welcome', titleColor: Colors.black, subtitle: 'Back', subtitleColor: Colors.black),
                        InputComponent(
                            label: 'Email',
                            name: 'email',
                            placeholder: 'Entrez votre adresse email',
                            displayPlaceholder: true,
                            validators: [
                              FormBuilderValidators.required(),
                              FormBuilderValidators.email(),
                            ]),
                        InputComponent(
                            label: 'Mot de passe',
                            name: 'password',
                            placeholder: 'Entrez votre mot de passe',
                            displayPlaceholder: true,
                            obscureText: true,
                            validators: [
                              FormBuilderValidators.required(),
                              FormBuilderValidators.minLength(8),
                            ]),
                        Container(
                          alignment: Alignment.bottomRight,
                          child: InkWell(
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordScreen())),
                            child: TextButtonAtom(label: 'Mot de passe oublié?', labelColor: Colors.grey, redirectTo: '/forgot-password'),
                          ),
                        ),
                        Center(
                          child: ElevatedButton(
                            onPressed: () => {
                              if (_loginFormKey.currentState!.validate())
                                {
                                  authBloc.add(LoginEvent(
                                    _loginFormKey.currentState?.fields['email']?.value,
                                    _loginFormKey.currentState?.fields['password']?.value,
                                  ))
                                }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orangeAccent[200],
                              fixedSize: const Size(400, 50),
                            ),
                            child: const Text('Se connecter',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                )),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Vous n\'avez pas de compte ?',
                              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                            TextButtonAtom(label: 'Inscrivez-vous', labelColor: Colors.orangeAccent, redirectTo: '/register'),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              )),
        ),
      ),
    );
  }
}
