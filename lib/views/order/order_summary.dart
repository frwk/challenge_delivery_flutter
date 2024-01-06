
import 'dart:ffi';

import 'package:challenge_delivery_flutter/atoms/button_atom.dart';
import 'package:challenge_delivery_flutter/bloc/auth/auth_bloc.dart';
import 'package:challenge_delivery_flutter/bloc/order/order_bloc.dart';
import 'package:challenge_delivery_flutter/bloc/payment/payment_bloc.dart';
import 'package:challenge_delivery_flutter/helpers/format_string.dart';
import 'package:challenge_delivery_flutter/models/order.dart';
import 'package:challenge_delivery_flutter/services/order/order_service.dart';
import 'package:challenge_delivery_flutter/widgets/layouts/app_bar.dart';
import 'package:challenge_delivery_flutter/widgets/layouts/client_layout.dart';
import 'package:challenge_delivery_flutter/widgets/order/arrow_connector.dart';
import 'package:challenge_delivery_flutter/widgets/order/order_cart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../enums/message_type_enum.dart';
import '../../helpers/loading_state.dart';
import '../../helpers/show_snack_message.dart';

class OrderSummaryScreen extends StatefulWidget {
  final Order? order;
  final OrderService? orderService;

  const OrderSummaryScreen({super.key, this.order, this.orderService});

  @override
  State<OrderSummaryScreen> createState() => _OrderSummaryScreenState();
}

class _OrderSummaryScreenState extends State<OrderSummaryScreen> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;

    final orderBloc = BlocProvider.of<OrderBloc>(context);
    final paymentBloc = BlocProvider.of<PaymentBloc>(context);
    final clientId = BlocProvider.of<AuthBloc>(context).state.user?.id;

    return BlocListener<OrderBloc, OrderState>(
      listener: (context, state) async {
        if (state is OrderLoadingState) {
          modalLoading(context);
        } else if (state is OrderAddressSuccessState) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderSummaryScreen(order: state.order!),
            ),
          );
        } else if (state is OrderConfirmedState) {
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const ClientLayout()), (route) => false);
          showSnackMessage(context, 'Commande confirmée', MessageTypeEnum.success);
        } else if (state is OrderFailureState) {
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const ClientLayout()), (route) => false);
          showSnackMessage(context, state.error, MessageTypeEnum.error);
        } else if (state is OrderSuccessState) {
          Navigator.of(context, rootNavigator: true).pop();
          showSnackMessage(context, 'Commande effectuée', MessageTypeEnum.success);
        } else if (state is OrderInitial) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: MyAppBar(
          title: 'Résumé de ma commande',
          onBackArrowClicked: () {
            orderBloc.add(OrderInitialEvent(orderBloc.state.order));
          },
        ),
        body: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
          const SizedBox(height: 16),
          OrderCard(title: 'Addresse de départ', content: order!.pickupAddress),
          const SizedBox(height: 3),
          const ArrowConnector(),
          const SizedBox(height: 3),
          OrderCard(title: 'Addresse d\'arrivée', content: order.dropoffAddress),
          const SizedBox(height: 50),
          OrderCard(title: 'Details de votre livraison', content: '' ,other: SizedBox(
            child: Column(
              children: [
                Row(
                  children: [
                    const Text('Mode de livraison: '),
                    Text(FormatString.capitalize(order.vehicle))
                  ],
                ),
                Row(
                  children: [
                    Text('Type de livraison: '),
                    Text(FormatString.capitalize(order.urgency))
                  ],
                )
              ],
            ),
          )),
          const SizedBox(height: 30),
          Text('Montant total de votre commande : ${order.total}€', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                    child: ButtonAtom(
                  data: 'Annuler',
                  color: Colors.green,
                  onTap: () => {orderBloc.add(OrderCanceledEvent())},
                )),
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ButtonAtom(
                      data: 'Commander', color: Colors.orangeAccent.shade200, onTap: () => {paymentBloc.add(PaymentIntentEvent(order.total!, 'EUR'))}),
                )),
              ],
            ),
          )
        ]),
      ),
    );
  }
}
