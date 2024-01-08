import 'package:challenge_delivery_flutter/atoms/button_atom.dart';
import 'package:challenge_delivery_flutter/bloc/auth/auth_bloc.dart';
import 'package:challenge_delivery_flutter/components/my_card.dart';
import 'package:challenge_delivery_flutter/enums/delivery_status_enum.dart';
import 'package:challenge_delivery_flutter/enums/message_type_enum.dart';
import 'package:challenge_delivery_flutter/helpers/show_snack_message.dart';
import 'package:challenge_delivery_flutter/models/delivery.dart';
import 'package:challenge_delivery_flutter/services/order/order_service.dart';
import 'package:challenge_delivery_flutter/enums/delivery_status_enum.dart';
import 'package:challenge_delivery_flutter/models/delivery.dart';
import 'package:challenge_delivery_flutter/services/order/order_service.dart';
import 'package:challenge_delivery_flutter/views/courier/delivery/delivery_details_screen.dart';
import 'package:challenge_delivery_flutter/widgets/layouts/courier_layout.dart';
import 'package:flutter/material.dart';
import 'package:challenge_delivery_flutter/helpers/secure_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timeline_tile/timeline_tile.dart';

class DeliveriesList extends StatefulWidget {
  final List<Delivery> deliveries;

  const DeliveriesList({super.key, required this.deliveries});

  @override
  State<DeliveriesList> createState() => _DeliveriesListState();
}

class _DeliveriesListState extends State<DeliveriesList> {
  late List<Delivery> sortedDeliveries;
  String sortOption = 'ascending';
  final storage = SecureStorage();
  bool isLoading = true;

  Future<void> initDeliveries() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });
    storage.delete('refused_deliveries');
    sortedDeliveries = List.from(widget.deliveries);
    List<String> refusedIDs = await storage.getRefusedDeliveries();
    if (!mounted) return;
    setState(() {
      sortedDeliveries = sortedDeliveries.where((delivery) {
        return !refusedIDs.contains(delivery.id.toString());
      }).toList();
      _sortDeliveries();
      isLoading = false;
    });
  }

  Future<void> onDeliveryRefused(String id) async {
    setState(() {
      sortedDeliveries = sortedDeliveries.where((delivery) => delivery.id.toString() != id).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    initDeliveries();
  }

  void _sortDeliveries() {
    if (sortOption == 'ascending') {
      sortedDeliveries.sort((a, b) => (a.distanceToPickup ?? 0).compareTo(b.distanceToPickup ?? 0));
    } else {
      sortedDeliveries.sort((a, b) => (b.distanceToPickup ?? 0).compareTo(a.distanceToPickup ?? 0));
    }
  }

  final List<Map<String, String>> sortOptions = [
    {'value': 'ascending', 'label': 'Distance du point de départ (croissant)'},
    {'value': 'descending', 'label': 'Distance du point de départ (décroissant)'},
  ];

  @override
  Widget build(BuildContext context) {
    final authBloc = BlocProvider.of<AuthBloc>(context);
    if (widget.deliveries.isEmpty) {
      return const Center(
        child: Text('Aucune livraison à effectuer autour de vous'),
      );
    }
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Column(
      children: [
        DropdownButton<String>(
          value: sortOption,
          items: sortOptions.map<DropdownMenuItem<String>>((option) {
            return DropdownMenuItem<String>(
              value: option['value'],
              child: Text(
                option['label']!,
                style: const TextStyle(fontSize: 14),
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              sortOption = newValue!;
              _sortDeliveries();
            });
          },
        ),
        Expanded(
          child: ListView.builder(
            itemCount: sortedDeliveries.length,
            itemBuilder: (context, index) {
              final delivery = sortedDeliveries[index];
              return MyCard(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                  title: Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Text('Livraison à ${delivery.distanceToPickup} mètres'),
                  ),
                  subtitle: Column(
                    children: [
                      TimelineTile(
                        isFirst: true,
                        endChild: Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Text(delivery.pickupAddress!, style: TextStyle(fontSize: 13, color: Colors.blueGrey[600])),
                        ),
                        indicatorStyle: const IndicatorStyle(width: 15, color: Colors.green),
                      ),
                      TimelineTile(
                        isLast: true,
                        endChild: Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Text(delivery.dropoffAddress!, style: TextStyle(fontSize: 13, color: Colors.blueGrey[600])),
                        ),
                        indicatorStyle: const IndicatorStyle(width: 15, color: Colors.red),
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward),
                  visualDensity: VisualDensity(vertical: 4),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DeliveryDetailsScreen(delivery: delivery, onDeliveryRefused: onDeliveryRefused, actionsButtons: [
                        ButtonAtom(
                          data: "Refuser",
                          color: Colors.red,
                          icon: Icons.close,
                          onTap: () async {
                            storage.refuseDelivery(delivery.id.toString());
                            await onDeliveryRefused(delivery.id.toString());
                            Navigator.pop(context);
                          },
                        ),
                        ButtonAtom(
                          data: "Accepter",
                          icon: Icons.check,
                          color: Colors.green,
                          onTap: () async {
                            try {
                              Delivery acceptedDelivery = await orderService.getDelivery(delivery.id!);
                              if (acceptedDelivery.status != DeliveryStatusEnum.pending.name) {
                                showSnackMessage(context, 'La livraison n\'est plus disponible', MessageTypeEnum.error);
                                Navigator.pop(context);
                              } else {
                                await orderService.updateDelivery(
                                    delivery.copyWith(status: DeliveryStatusEnum.accepted.name, courierId: () => authBloc.state.user!.courier!.id));
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const CourierLayout(
                                      initialPage: 'map',
                                    ),
                                  ),
                                );
                              }
                            } catch (e) {
                              showSnackMessage(context, 'Une erreur s\'est produite', MessageTypeEnum.error);
                              Navigator.pop(context);
                            }
                          },
                        ),
                      ]),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
