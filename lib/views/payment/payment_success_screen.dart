import 'package:challenge_delivery_flutter/atoms/button_atom.dart';
import 'package:flutter/material.dart';

class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image(image: AssetImage('assets/img/payment/payment_successful.png'), height: 150,),
          Text('Paiement effectué avec succès !'),
          ButtonAtom(
              data: 'Tracker mon livreur',
              color: Colors.orangeAccent,
              buttonSize: ButtonSize.medium,
          )
        ],
      ));
  }
}
