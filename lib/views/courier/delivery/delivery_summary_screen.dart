import 'package:challenge_delivery_flutter/bloc/delivery%20copy/delivery_tracking_bloc.dart';
import 'package:challenge_delivery_flutter/bloc/delivery%20copy/delivery_tracking_state.dart';
import 'package:challenge_delivery_flutter/enums/delivery_status_enum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:challenge_delivery_flutter/atoms/button_atom.dart';
import 'package:challenge_delivery_flutter/models/delivery.dart';
import 'package:challenge_delivery_flutter/widgets/layouts/courier_layout.dart';
import 'package:geolocator/geolocator.dart';

class DeliverySummaryScreen extends StatefulWidget {
  final Delivery delivery;

  const DeliverySummaryScreen({super.key, required this.delivery});

  @override
  State<DeliverySummaryScreen> createState() => _DeliverySummaryScreenState();
}

class _DeliverySummaryScreenState extends State<DeliverySummaryScreen> {
  bool isLoading = true;
  String? pickupAddress;
  String? dropoffAddress;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final deliveryBloc = BlocProvider.of<DeliveryTrackingBloc>(context);

    return BlocBuilder<DeliveryTrackingBloc, DeliveryTrackingState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Récapitulatif de la livraison',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
            centerTitle: true,
          ),
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Card(
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      state.delivery?.status == DeliveryStatusEnum.delivered.name ? 'Livraison terminée !' : 'Livraison annulée',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepOrange),
                    ),
                    const Divider(height: 30, thickness: 2),
                    InfoRow('Adresse de prise en charge:', deliveryBloc.pickupAddress ?? 'Chargement...'),
                    const SizedBox(height: 10),
                    InfoRow('Adresse de livraison:', deliveryBloc.dropoffAddress ?? 'Chargement...'),
                    if (state.delivery?.status == DeliveryStatusEnum.delivered.name) ...[
                      const Divider(height: 30, thickness: 2),
                      InfoRow('Durée de la livraison:', '${widget.delivery.dropoffDate!.difference(widget.delivery.pickupDate!).inMinutes} minutes'),
                      InfoRow(
                          'Distance parcourue:',
                          '${Geolocator.distanceBetween(
                            widget.delivery.pickupLatitude!,
                            widget.delivery.pickupLongitude!,
                            widget.delivery.dropoffLatitude!,
                            widget.delivery.dropoffLongitude!,
                          ).roundToDouble().toInt()} m'),
                    ],
                    const Divider(height: 30, thickness: 2),
                    ButtonAtom(
                      data: "Retourner à l'accueil",
                      onTap: () =>
                          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const CourierLayout()), (route) => false),
                      buttonSize: ButtonSize.small,
                    ),
                    if (state.delivery?.status == DeliveryStatusEnum.delivered.name) ...[
                      const SizedBox(height: 10),
                      const ButtonAtom(
                        data: "Contacter le support",
                        buttonSize: ButtonSize.small,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget InfoRow(String label, String value) {
    return Row(
      children: [
        Expanded(
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
        Expanded(
          child: Text(value, style: const TextStyle(fontSize: 16)),
        ),
      ],
    );
  }
}
