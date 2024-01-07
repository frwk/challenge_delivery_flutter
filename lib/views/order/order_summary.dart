import 'package:challenge_delivery_flutter/atoms/button_atom.dart';
import 'package:challenge_delivery_flutter/bloc/auth/auth_bloc.dart';
import 'package:challenge_delivery_flutter/bloc/order/order_bloc.dart';
import 'package:challenge_delivery_flutter/enums/vehicle_enum.dart';
import 'package:challenge_delivery_flutter/helpers/format_string.dart';
import 'package:challenge_delivery_flutter/models/order.dart';
import 'package:challenge_delivery_flutter/widgets/layouts/app_bar.dart';
import 'package:challenge_delivery_flutter/widgets/layouts/client_layout.dart';
import 'package:challenge_delivery_flutter/widgets/order/arrow_connector.dart';
import 'package:challenge_delivery_flutter/widgets/order/order_cart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
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
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              OrderCard(title: 'Addresse de départ', content: order!.pickupAddress, icon: Icons.location_on),
              const SizedBox(height: 3),
              Center(child: const ArrowConnector()),
              const SizedBox(height: 3),
              OrderCard(title: 'Addresse d\'arrivée', content: order.dropoffAddress, icon: Icons.flag),
              const SizedBox(height: 50),
              const Center(child: Text('Détails de votre commande', style: TextStyle(fontSize: 16))),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: DeliveryDetail(
                      icon: Icons.delivery_dining,
                      title: 'Véhicule',
                      detail: '${FormatString.capitalize(translateVehicleEnum(order.vehicle))}',
                      color: Colors.white,
                    ),
                  ),
                  Expanded(
                    child: DeliveryDetail(
                      icon: Icons.speed,
                      title: 'Mode',
                      detail: '${FormatString.capitalize(order.urgency)}',
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: DeliveryDetail(
                      icon: Icons.access_time,
                      title: 'Arrivée estimée',
                      detail: '${estimateArrival(order.duration!)}',
                      color: Colors.white,
                    ),
                  ),
                  Expanded(
                    child: DeliveryDetail(
                      icon: Icons.euro_symbol,
                      title: 'Montant total',
                      detail: '${order.total}€',
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
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
                          data: 'Commander',
                          color: Colors.orangeAccent.shade200,
                          onTap: () => {orderBloc.add(OrderConfirmedEvent(order, clientId!, order.total!, 'EUR'))}),
                    )),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  String estimateArrival(int travelTimeInSeconds) {
    DateTime currentTime = DateTime.now();
    DateTime arrivalTime = currentTime.add(Duration(seconds: travelTimeInSeconds));
    String formattedArrivalTime = DateFormat('HH\'h\'mm').format(arrivalTime);
    return formattedArrivalTime;
  }
}

class DeliveryDetail extends StatelessWidget {
  final IconData icon;
  final String title;
  final String detail;
  final Color color;

  const DeliveryDetail({
    Key? key,
    required this.icon,
    required this.title,
    required this.detail,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 30, color: Colors.black),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              ),
              Text(detail, style: const TextStyle(color: Colors.black)),
            ],
          ),
        ],
      ),
    );
  }
}
