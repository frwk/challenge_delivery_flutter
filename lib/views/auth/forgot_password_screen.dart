import 'package:challenge_delivery_flutter/views/auth/check_email_screen.dart';
import 'package:challenge_delivery_flutter/views/auth/login_screen.dart';
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
  final _formKey = GlobalKey<FormState>();

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Réinitialiser le mot de passe',
            style: TextStyle(fontSize: 21, fontWeight: FontWeight.w500)),
        centerTitle: true,
        leadingWidth: 80,
        leading: InkWell(
          onTap: () => Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const LoginScreen())),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.arrow_back_ios_new_rounded,
                  size: 18, color: Theme.of(context).colorScheme.primary),
              Text('Back',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 16))
            ],
          ),
        ),
        actions: const [
          Icon(Icons.help_outline_outlined, color: Colors.black),
          SizedBox(width: 15.0),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            children: [
              const Text(
                'Entrez l\'email associé à votre compte et nous vous enverrons un email avec des instructions pour réinitialiser votre mot de passe.',
                maxLines: 4,
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30.0),
              FormBuilderTextField(
                name: 'email',
                decoration: const InputDecoration(labelText: 'Email'),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.email(),
                ]),
              ),
              const SizedBox(height: 30.0),
              ElevatedButton(
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const CheckEmailScreen())),
                child: const Text('Envoyer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
