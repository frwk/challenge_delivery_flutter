import 'dart:io';
import 'package:challenge_delivery_flutter/views/auth/login/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:android_intent_plus/android_intent.dart';

class CheckEmailScreen extends StatelessWidget {
  const CheckEmailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  const SizedBox(height: 90.0),
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      margin: const EdgeInsets.only(top: 50.0),
                      height: 110,
                      width: 110,
                      decoration:
                          BoxDecoration(color: Theme.of(context).colorScheme.primary.withOpacity(.1), borderRadius: BorderRadius.circular(20.0)),
                      child: Icon(FontAwesomeIcons.envelopeOpenText, size: 60, color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  const Text(
                    'Vérifiez vos mails',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 32),
                  ),
                  const SizedBox(height: 20.0),
                  const Text('Un mail vous a été envoyé pour réinitialiser votre mot de passe.', textAlign: TextAlign.center),
                  const SizedBox(height: 40.0),
                  Container(
                      margin: const EdgeInsets.symmetric(horizontal: 70.0),
                      child: TextButton(
                        child: const Text(
                          'Ouvrir l\'application mail',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        onPressed: () async {
                          if (Platform.isAndroid) {
                            const intent = AndroidIntent(action: 'action_view', package: 'com.android.email');
                            intent.launch();
                          }
                        },
                      )),
                  const SizedBox(height: 40.0),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 70.0),
                    child: InkWell(
                      onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                      child: const Text('Je confirmerai plus tard'),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                ],
              ),
              Container(
                  margin: const EdgeInsets.only(bottom: 15.0),
                  child: const Text(
                    'Email non reçu? Vérifiez vos spams.',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
