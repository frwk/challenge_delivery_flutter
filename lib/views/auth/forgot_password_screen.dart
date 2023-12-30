import 'package:challenge_delivery_flutter/atoms/button_atom.dart';
import 'package:challenge_delivery_flutter/components/input_component.dart';
import 'package:challenge_delivery_flutter/views/auth/check_email_screen.dart';
import 'package:challenge_delivery_flutter/views/auth/login/login_screen.dart';
import 'package:challenge_delivery_flutter/widgets/layouts/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  late TextEditingController _emailController;
  final _forgotPasswordFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    _emailController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _emailController.clear();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: const MyAppBar(title: 'Mot de passe oublié'),
      body: SafeArea(
        child: Form(
          key: _forgotPasswordFormKey,
          child: ListView(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            children:  [
              const Text(
                'Entrez l\'email associé à votre compte et nous vous enverrons un email avec des instructions pour réinitialiser votre mot de passe.',
                maxLines: 4,
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30.0),
              InputComponent(label: 'Email', name:'email', placeholder: 'Entrez votre adresse email', displayPlaceholder: true ,validators: [
                FormBuilderValidators.required(),
                FormBuilderValidators.email(),
              ]),
              const SizedBox(height: 30.0),
              ButtonAtom(data: 'Envoyer', onTap: () => {
                  if (_forgotPasswordFormKey.currentState!.validate()) {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const CheckEmailScreen()))
                  }
              }
              )
            ],
          ),
        ),
      ),
    );
  }
}
