import 'package:challenge_delivery_flutter/models/order.dart';
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
    final departureAddress = order?.departureAddress;
    print(widget.order?.departureAddress);
    return const Scaffold(
      body: Center(
        child: Text(departureAddress ?? 'null'),
      ),
    );
  }
}
