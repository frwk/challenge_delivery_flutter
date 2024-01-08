import 'package:challenge_delivery_flutter/atoms/button_atom.dart';
import 'package:challenge_delivery_flutter/bloc/auth/auth_bloc.dart';
import 'package:challenge_delivery_flutter/components/input_component.dart';
import 'package:challenge_delivery_flutter/enums/custom_password_strength_enum.dart';
import 'package:challenge_delivery_flutter/enums/message_type_enum.dart';
import 'package:challenge_delivery_flutter/helpers/show_snack_message.dart';
import 'package:challenge_delivery_flutter/models/user.dart';
import 'package:challenge_delivery_flutter/services/user_service.dart';
import 'package:challenge_delivery_flutter/widgets/layouts/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'dart:developer' as developer;

import 'package:password_strength_checker/password_strength_checker.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormBuilderState>();

  String? _currentPasswordError;
  bool _isActualPasswordVisible = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  late User user;

  final passNotifier = ValueNotifier<CustomPasswordStrength?>(null);

  @override
  void initState() {
    super.initState();
    user = BlocProvider.of<AuthBloc>(context).state.user!;
  }

  Future<bool> _validateCurrentPassword() async {
    final actualPassword = _formKey.currentState!.fields['actualPassword']?.value;
    final passwordMatch = await UserService().verifyPassword(user.id, actualPassword);
    if (!passwordMatch) {
      setState(() {
        _currentPasswordError = 'Le mot de passe actuel est incorrect';
      });
      return false;
    }
    setState(() {
      _currentPasswordError = null;
    });
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        print(state.toString());
        if (state is FailureUpdateProfileState) {
          showSnackMessage(context, state.error, MessageTypeEnum.error);
        } else if (state is SuccessUpdateProfileState) {
          showSnackMessage(context, 'Mot de passe mis à jour avec succès', MessageTypeEnum.success);
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: const MyAppBar(title: 'Changer le mot de passe'),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: FormBuilder(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  InputComponent(
                    name: 'actualPassword',
                    placeholder: 'Mot de passe actuel',
                    displayPlaceholder: true,
                    obscureText: !_isActualPasswordVisible,
                    errorText: _currentPasswordError,
                    suffixIcon: IconButton(
                      icon: Icon(_isActualPasswordVisible ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _isActualPasswordVisible = !_isActualPasswordVisible),
                    ),
                    validators: [
                      FormBuilderValidators.required(errorText: 'Veuillez entrer votre mot de passe actuel'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Divider(
                    color: Colors.grey[400],
                  ),
                  InputComponent(
                      name: 'password',
                      placeholder: 'Nouveau mot de passe',
                      displayPlaceholder: true,
                      onChanged: (value) {
                        passNotifier.value = CustomPasswordStrength.calculate(text: value ?? '');
                      },
                      obscureText: !_isPasswordVisible,
                      suffixIcon: IconButton(
                        icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                      ),
                      validators: [FormBuilderValidators.required(), FormBuilderValidators.minLength(8)]),
                  const SizedBox(height: 30),
                  PasswordStrengthChecker<CustomPasswordStrength>(
                    strength: passNotifier,
                    configuration: const PasswordStrengthCheckerConfiguration(borderWidth: 0, width: 300, height: 10),
                  ),
                  const SizedBox(height: 20),
                  InputComponent(
                      name: 'confirmPassword',
                      placeholder: 'Confirmez le nouveau mot de passe',
                      displayPlaceholder: true,
                      obscureText: !_isConfirmPasswordVisible,
                      suffixIcon: IconButton(
                        icon: Icon(_isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                      ),
                      validators: [
                        FormBuilderValidators.required(),
                        (value) => _formKey.currentState?.fields['password']?.value != value ? 'Mots de passe différents' : null
                      ]),
                  const SizedBox(height: 20),
                  ButtonAtom(
                    data: 'Enregistrer les modifications',
                    onTap: () async {
                      setState(() {
                        _currentPasswordError = null;
                      });
                      await Future.delayed(const Duration(milliseconds: 500));
                      if (_formKey.currentState!.saveAndValidate()) {
                        if (!await _validateCurrentPassword()) return;
                        BlocProvider.of<AuthBloc>(context).add(UpdatePasswordEvent(
                          password: _formKey.currentState!.fields['password']?.value,
                        ));
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
