import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_stripe/flutter_stripe.dart';

import '../../main.dart';

class StripePaymentService {
  Map<String, dynamic>? paymentIntent;

  Future<void> stripeMakePayment(int amount, String currency) async {
    try {
      paymentIntent = await createPaymentIntent(amount, currency);
      var gpay = const PaymentSheetGooglePay(
          merchantCountryCode: "FR",
          currencyCode: "EUR",
          testEnv: true
      );

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent!['client_secret'],
          style: ThemeMode.light,
          merchantDisplayName: 'Coursier Inc.',
          googlePay: gpay,
      ));

      displayPaymentSheet();
    } catch (e) {
      print(e.toString());
      // Fluttertoast.showToast(msg: e.toString());
    }
  }

  displayPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet();
      await Future.delayed(const Duration(milliseconds: 850));
      await navigatorKey.currentState!.pushNamed('/payment-success');

    } on Exception catch (e) {
      if (e is StripeException) {
        // Fluttertoast.showToast(
        //     msg: 'Error from Stripe: ${e.error.localizedMessage}');
      } else {
        // Fluttertoast.showToast(msg: 'Unforeseen error: ${e}');
      }
    }
  }

//create Payment
  createPaymentIntent(int amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': calculateAmount(amount),
        'currency': currency,
      };

      //Make post request to Stripe
      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer ${dotenv.env['STRIPE_API_KEY']}',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: body,
      );
      return await json.decode(response.body);
    } catch (err) {
      throw Exception(err.toString());
    }
  }

  calculateAmount(int amount) {
    final calculatedAmount = amount * 100;
    return calculatedAmount.toString();
  }
}

final paymentService = StripePaymentService();
