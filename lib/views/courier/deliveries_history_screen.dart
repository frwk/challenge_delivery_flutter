import 'dart:convert';

import 'package:challenge_delivery_flutter/atoms/button_atom.dart';
import 'package:challenge_delivery_flutter/bloc/auth/auth_bloc.dart';
import 'package:challenge_delivery_flutter/components/my_card.dart';
import 'package:challenge_delivery_flutter/components/my_chip.dart';
import 'package:challenge_delivery_flutter/enums/delivery_status_enum.dart';
import 'package:challenge_delivery_flutter/enums/message_type_enum.dart';
import 'package:challenge_delivery_flutter/enums/role_enum.dart';
import 'package:challenge_delivery_flutter/exceptions/not_found_exception.dart';
import 'package:challenge_delivery_flutter/helpers/show_snack_message.dart';
import 'package:challenge_delivery_flutter/models/complaint.dart';
import 'package:challenge_delivery_flutter/models/delivery.dart';
import 'package:challenge_delivery_flutter/models/user.dart';
import 'package:challenge_delivery_flutter/services/complaint/complaint_service.dart';
import 'package:challenge_delivery_flutter/services/order/order_service.dart';
import 'package:challenge_delivery_flutter/views/complaint/complaint_detail_screen_args.dart';
import 'package:challenge_delivery_flutter/views/courier/delivery/delivery_details_screen.dart';
import 'package:challenge_delivery_flutter/widgets/deliveries_list.dart';
import 'package:challenge_delivery_flutter/widgets/layouts/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'dart:developer' as developer;
import 'package:timeline_tile/timeline_tile.dart';

class Order {
  final String id;
  final String date;
  final String status;
  final double amount;
  late final AuthBloc authBloc;

  Order({required this.id, required this.date, required this.status, required this.amount});
}

class DeliveriesHistoryScreen extends StatefulWidget {
  const DeliveriesHistoryScreen({super.key});

  @override
  _DeliveriesHistoryScreenState createState() => _DeliveriesHistoryScreenState();
}

class _DeliveriesHistoryScreenState extends State<DeliveriesHistoryScreen> {
  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('dd/MM/yyyy à H\'h\'mm').format(date);
  }

  Color _getStatusColor(String? status) {
    if (status == DeliveryStatusEnum.delivered.name) return Colors.green;
    if (status == DeliveryStatusEnum.cancelled.name) return Colors.red;
    return Colors.orange;
  }

  String _getStatusText(String? status) {
    if (status == DeliveryStatusEnum.delivered.name) return 'Livré';
    if (status == DeliveryStatusEnum.cancelled.name) return 'Annulé';
    return 'En cours';
  }

  @override
  Widget build(BuildContext context) {
    final authBloc = BlocProvider.of<AuthBloc>(context);

    return Scaffold(
        appBar: const MyAppBar(
          title: 'Historique des livraisons',
        ),
        body: FutureBuilder<List<Delivery>>(
          future: _getDeliveriesBasedOnRole(authBloc),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Erreur: ${snapshot.error}'));
            } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              return _buildDeliveryList(snapshot.data!, authBloc.state.user!);
            } else {
              return const Center(child: Text('Aucune livraison effectuée'));
            }
          },
        ));
  }

  Future<List<Delivery>> _getDeliveriesBasedOnRole(AuthBloc authBloc) async {
    try {
      if (authBloc.state.user?.role == RoleEnum.client.name) {
        return await OrderService().getUserDeliveries(authBloc.state.user!);
      } else {
        return await OrderService().getCourierDeliveries(authBloc.state.user!.courier!);
      }
    } catch (e) {
      return Future<List<Delivery>>.error(e.toString());
    }
  }

  Widget _buildTimeline(Delivery delivery) {
    return Column(
      children: [
        TimelineTile(
          isFirst: true,
          endChild: _buildAddressText(delivery.pickupAddress!),
          indicatorStyle: const IndicatorStyle(width: 15, color: Colors.green),
        ),
        TimelineTile(
          isLast: true,
          endChild: _buildAddressText(delivery.dropoffAddress!),
          indicatorStyle: const IndicatorStyle(width: 15, color: Colors.red),
        ),
      ],
    );
  }

  Widget _buildAddressText(String address) {
    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: Text(address, style: TextStyle(fontSize: 13, color: Colors.blueGrey[600])),
    );
  }

  Widget _buildDeliveryList(List<Delivery> deliveries, User user) {
    return ListView.builder(
      itemCount: deliveries.length,
      itemBuilder: (context, index) {
        Delivery delivery = deliveries[index];
        return _buildDeliveryListItem(delivery, user);
      },
    );
  }

  Widget _buildDeliveryListItem(Delivery delivery, User user) {
    return MyCard(
      child: InkWell(
        onTap: () => _onDeliveryTap(delivery, user),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text('Livraison #${delivery.id}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                MyChip(text: _getStatusText(delivery.status!), color: _getStatusColor(delivery.status!)),
              ],
            ),
            SizedBox(height: 20),
            _buildTimeline(delivery),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${_formatDate(delivery.createdAt)}', style: TextStyle(color: Colors.blueGrey[600])),
                Row(
                  children: List.generate(delivery.notation ?? 0, (index) => Icon(Icons.star, color: Colors.amber, size: 20)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _contactSupportAction(BuildContext context, Delivery delivery, User user) async {
    try {
      List<Complaint> complaints = await ComplaintService().findByUserAndDeliveryId(user.id, delivery.id!);
      if (complaints.any((complaint) => complaint.status == 'pending')) {
        Navigator.pushNamed(context, '/complaint-detail',
            arguments: ComplaintDetailScreenArgs(complaint: complaints.firstWhere((complaint) => complaint.status == 'pending')));
      } else {
        throw NotFoundException('Complaint already resolved');
      }
    } catch (e) {
      if (e is NotFoundException) {
        Complaint complaint = await ComplaintService().create(Complaint(
          deliveryId: delivery.id,
          userId: user.id,
        ));
        Navigator.pushNamed(context, '/complaint-detail', arguments: ComplaintDetailScreenArgs(complaint: complaint));
      }
      print(e);
    }
  }

  Future<void> _cancelOrderAction(BuildContext context, Delivery delivery, User user) async {
    try {
      Delivery cancelledDelivery = delivery.copyWith(status: DeliveryStatusEnum.cancelled.name);
      developer.log(jsonEncode(cancelledDelivery));
      await OrderService().updateDelivery(cancelledDelivery);
      showSnackMessage(context, 'Commande annulée avec succès', MessageTypeEnum.success);
      setState(() {});
      Navigator.pop(context);
    } catch (e) {
      showSnackMessage(context, 'Erreur lors de l\'annulation de la commande, veuillez contacter le support.', MessageTypeEnum.error);
      print(e);
    }
  }

  void _onDeliveryTap(Delivery delivery, User user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DeliveryDetailsScreen(
          delivery: delivery,
          menuActions: [
            if (delivery.status == DeliveryStatusEnum.pending.name)
              MenuAction(
                title: 'Annuler la commande',
                action: () {
                  _cancelOrderAction(context, delivery, user);
                },
              ),
            MenuAction(
              title: 'Contacter le support',
              action: () {
                _contactSupportAction(context, delivery, user);
              },
            ),
          ],
          actionsButtons: [
            if (delivery.status == DeliveryStatusEnum.pending.name)
              ButtonAtom(
                data: 'Annuler',
                icon: Icons.cancel,
                color: Colors.red,
                onTap: () => _cancelOrderAction(context, delivery, user),
              ),
            ButtonAtom(
              data: "Support",
              icon: Icons.support,
              color: Colors.amber,
              onTap: () => _contactSupportAction(context, delivery, user),
            ),
          ],
        ),
      ),
    );
  }
}
