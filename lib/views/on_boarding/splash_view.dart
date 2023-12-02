
import 'package:challenge_delivery_flutter/listener/checking_login_listener.dart';
import 'package:flutter/material.dart';


class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {

  @override
  void initState() {
    super.initState();
    goWelcomePage();
  }

  void goWelcomePage() {
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const CheckingLoginListener()));
    });
  }

  @override
  Widget build(BuildContext context) {

    var media = MediaQuery.of(context).size;

    return Scaffold(
      body: Column(
        children: [
          Center(
            child: Image.asset(
              'assets/img/splash/splash_view.png',
              width: media.width,
              height: media.height,
              fit: BoxFit.contain
            ),
          ),
        ],
      )
    );
  }
}
