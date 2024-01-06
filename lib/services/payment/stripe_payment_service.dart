import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_stripe/flutter_stripe.dart';

class StripePaymentService {
  Map<String, dynamic>? paymentIntent;

  Future<void> stripeMakePayment() async {
    try {
      paymentIntent = await createPaymentIntent(100, 'EUR');
      var gpay = const PaymentSheetGooglePay(
          merchantCountryCode: "EUR",
          currencyCode: "EUR",
          testEnv: true
      );

      await Stripe.instance.initPaymentSheet(paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: paymentIntent!['client_secret'],
        style: ThemeMode.light,
        merchantDisplayName: 'Coursier Inc.',
        googlePay: gpay,
      ));

      //STEP 3: Display Payment sheet
      displayPaymentSheet();
    } catch (e) {
      print(e.toString());
      // Fluttertoast.showToast(msg: e.toString());
    }
  }

  displayPaymentSheet() async {
    print('payment sheet');
    try {
      await Stripe.instance.presentPaymentSheet();
      print('Done');

      // Fluttertoast.showToast(msg: 'Payment succesfully completed');
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
      //Request body
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

//calculate Amount
  calculateAmount(int amount) {
    final calculatedAmount = amount * 100;
    return calculatedAmount.toString();
  }
}

final paymentService = StripePaymentService();
