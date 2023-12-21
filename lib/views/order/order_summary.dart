import 'package:challenge_delivery_flutter/atoms/button_atom.dart';
import 'package:challenge_delivery_flutter/bloc/auth/auth_bloc.dart';
import 'package:challenge_delivery_flutter/bloc/order/order_bloc.dart';
import 'package:challenge_delivery_flutter/bloc/user/user_bloc.dart';
import 'package:challenge_delivery_flutter/components/my_card.dart';
import 'package:challenge_delivery_flutter/models/order.dart';
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
  const OrderSummaryScreen({super.key, this.order});

  @override
  State<OrderSummaryScreen> createState() => _OrderSummaryScreenState();
}

class _OrderSummaryScreenState extends State<OrderSummaryScreen> {
  @override
  Widget build(BuildContext context) {
    final order = widget.order;

    final orderBloc = BlocProvider.of<OrderBloc>(context);
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
          OrderCard(title: 'Addresse de départ', address: order!.pickupAddress),
          const SizedBox(height: 5),
          const ArrowConnector(),
          const SizedBox(height: 5),
          OrderCard(title: 'Addresse d\'arrivée', address: order.dropoffAddress),
          const SizedBox(height: 25),
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
                      data: 'Commander', color: Colors.orangeAccent.shade200, onTap: () => {orderBloc.add(OrderConfirmedEvent(order, clientId!))}),
                )),
              ],
            ),
          )
        ]),
      ),
    );
  }
}
