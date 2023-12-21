import 'package:challenge_delivery_flutter/atoms/button_atom.dart';
import 'package:challenge_delivery_flutter/bloc/auth/auth_bloc.dart';
import 'package:challenge_delivery_flutter/enums/delivery_status_enum.dart';
import 'package:challenge_delivery_flutter/helpers/secure_storage.dart';
import 'package:challenge_delivery_flutter/services/location_service.dart';
import 'package:challenge_delivery_flutter/services/order/order_service.dart';
import 'package:challenge_delivery_flutter/widgets/layouts/courier_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:challenge_delivery_flutter/models/delivery.dart';

class DeliveryDetailsScreen extends StatefulWidget {
  final Delivery delivery;
  final Future<void> Function(String) onDeliveryRefused;

  const DeliveryDetailsScreen({super.key, required this.delivery, required this.onDeliveryRefused});

  @override
  State<DeliveryDetailsScreen> createState() => _DeliveryDetailsScreenState();
}

class _DeliveryDetailsScreenState extends State<DeliveryDetailsScreen> {
  final storage = SecureStorage();
  bool isLoading = true;
  String? pickupAddress;
  String? dropoffAddress;

  Future<void> loadAddresses() async {
    try {
      String fetchedPickupAddress = await locationService.getAddress(widget.delivery.pickupLatitude!, widget.delivery.pickupLongitude!);
      String fetchedDropoffAddress = await locationService.getAddress(widget.delivery.dropoffLatitude!, widget.delivery.dropoffLongitude!);

      setState(() {
        pickupAddress = fetchedPickupAddress;
        dropoffAddress = fetchedDropoffAddress;
        isLoading = false;
      });
    } catch (error) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    loadAddresses();
  }

  @override
  Widget build(BuildContext context) {
    final authBloc = BlocProvider.of<AuthBloc>(context);

    return Scaffold(
      appBar: AppBar(
          title: Text(
            'Détails de la Livraison #${widget.delivery.id}',
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          )),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCard(
              Icons.person,
              'Client',
              '${widget.delivery.client?.firstName} ${widget.delivery.client?.lastName}',
            ),
            _buildCard(
              Icons.location_on,
              'Adresse de départ',
              pickupAddress ?? '${widget.delivery.pickupLatitude.toString()}, ${widget.delivery.pickupLongitude.toString()}',
            ),
            _buildCard(
              Icons.home,
              'Adresse de livraison',
              dropoffAddress ?? '${widget.delivery.dropoffLatitude.toString()}, ${widget.delivery.dropoffLongitude.toString()}',
            ),
            _buildCard(
              Icons.calendar_today,
              'Date de la demande',
              DateFormat('dd/MM/yyyy à HH\'h\'mm').format(widget.delivery.pickupDate?.toLocal() ?? DateTime.now()),
            ),
            _buildCard(
              Icons.map,
              'Distance à parcourir',
              '${widget.delivery.distance} mètres',
            ),
            _buildCard(
              Icons.directions_walk,
              'Distance du point de départ',
              '${widget.delivery.distanceToPickup} mètres',
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ButtonAtom(
                  data: "Refuser",
                  color: Colors.red,
                  icon: Icons.close,
                  onTap: () async {
                    storage.refuseDelivery(widget.delivery.id.toString());
                    await widget.onDeliveryRefused(widget.delivery.id.toString());
                    Navigator.pop(context);
                  },
                ),
                ButtonAtom(
                  data: "Accepter",
                  icon: Icons.check,
                  color: Colors.green,
                  onTap: () async {
                    await orderService.updateDelivery(
                        widget.delivery.copyWith(status: DeliveryStatusEnum.accepted.name, courierId: () => authBloc.state.user!.courier!.id));
                    Navigator.pushAndRemoveUntil(
                        context, MaterialPageRoute(builder: (context) => const CourierLayout(initialPage: 'map')), (route) => false);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(IconData icon, String title, String subtitle) {
    return Card(
      elevation: 4.0,
      shadowColor: Colors.grey.withOpacity(0.5),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
      ),
    );
  }
}
