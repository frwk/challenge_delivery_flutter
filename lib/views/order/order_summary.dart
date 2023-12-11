import 'package:challenge_delivery_flutter/components/my_card.dart';
import 'package:challenge_delivery_flutter/models/order.dart';
import 'package:challenge_delivery_flutter/widgets/layouts/app_bar.dart';
import 'package:challenge_delivery_flutter/widgets/order/arrow_connector.dart';
import 'package:challenge_delivery_flutter/widgets/order/order_cart.dart';
import 'package:flutter/material.dart';

class OrderSummaryScreen extends StatefulWidget {
  final Order? order;
  const OrderSummaryScreen({super.key, this.order});

  @override
  State<OrderSummaryScreen> createState() => _OrderSummaryScreenState();
}

class _OrderSummaryScreenState extends State<OrderSummaryScreen> {
  @override
  Widget build(BuildContext context) {
    final order = widget.order;

    return Scaffold(
      appBar: const MyAppBar(title: 'Résumé de ma commande'),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          OrderCard(title: 'Addresse de départ', address: order!.departureAddress),
          const SizedBox(height: 5),
          const ArrowConnector(),
          const SizedBox(height: 5),
          OrderCard(title: 'Addresse d\'arrivée', address: order!.arrivalAddress),
          const SizedBox(height: 55),
          const Text('Details du produit', style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          )),
          const SizedBox(height: 25),
          MyCard(child: Column(
           children: [
             const Text('Type de produit'),
             const SizedBox(height: 25),
             Row(
               mainAxisAlignment: MainAxisAlignment.spaceAround,
             children: [
              Text('Nom : ${order!.packageType}' ),
              Text('Poids : ${order!.packageWeight}' ),
             ])
           ],
         ))
        ]
      ),
    );
  }
}
