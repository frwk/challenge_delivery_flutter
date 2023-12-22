import 'package:challenge_delivery_flutter/atoms/button_atom.dart';
import 'package:challenge_delivery_flutter/bloc/delivery%20copy/delivery_tracking_bloc.dart';
import 'package:challenge_delivery_flutter/bloc/delivery%20copy/delivery_tracking_event.dart';
import 'package:challenge_delivery_flutter/bloc/delivery%20copy/delivery_tracking_state.dart';
import 'package:challenge_delivery_flutter/enums/delivery_status_enum.dart';
import 'package:challenge_delivery_flutter/models/delivery.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

class DeliveryInfos extends StatelessWidget {
  final Delivery delivery;

  const DeliveryInfos({super.key, required this.delivery});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15.0),
      height: 183,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.0),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(.5), blurRadius: 7, spreadRadius: 5)]),
      child: Column(
        children: [
          BlocBuilder<DeliveryTrackingBloc, DeliveryTrackingState>(builder: (context, state) {
            if (state.status.isStarted && state.location != null && state.delivery != null) {
              final deliveryTrackingBloc = BlocProvider.of<DeliveryTrackingBloc>(context);
              double remainingDistance = _calculateRemainingDistance(state, delivery);
              return Column(
                children: [
                  _buildAddressRow(deliveryTrackingBloc, delivery),
                  const Divider(),
                  _buildClientInfoRow(deliveryTrackingBloc),
                  _buildActionButtonRow(deliveryTrackingBloc, state, remainingDistance),
                ],
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          }),
        ],
      ),
    );
  }

  double _calculateRemainingDistance(DeliveryTrackingState state, Delivery delivery) {
    return state.delivery!.status == DeliveryStatusEnum.accepted.name
        ? Geolocator.distanceBetween(state.location!.latitude, state.location!.longitude, delivery.pickupLatitude!, delivery.pickupLongitude!)
        : Geolocator.distanceBetween(state.location!.latitude, state.location!.longitude, delivery.dropoffLatitude!, delivery.dropoffLongitude!);
  }

  Widget _buildAddressRow(DeliveryTrackingBloc deliveryTrackingBloc, Delivery delivery) {
    return Row(
      children: [
        const Icon(Icons.location_on_outlined, size: 28, color: Colors.black87),
        const SizedBox(width: 15.0),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Adresse', style: TextStyle(fontWeight: FontWeight.w500)),
            Text(delivery.status == DeliveryStatusEnum.picked_up.name ? deliveryTrackingBloc.dropoffAddress : deliveryTrackingBloc.pickupAddress,
                style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        )
      ],
    );
  }

  Widget _buildClientInfoRow(DeliveryTrackingBloc deliveryTrackingBloc) {
    return Row(
      children: [
        Text("${deliveryTrackingBloc.client.firstName} ${deliveryTrackingBloc.client.lastName}"),
        const Spacer(),
        InkWell(
          onTap: () async => await makePhoneCall('+33654215421'),
          child: Container(
            height: 30,
            width: 30,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0), color: Colors.green),
            child: const Icon(Icons.phone, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtonRow(DeliveryTrackingBloc deliveryTrackingBloc, DeliveryTrackingState state, double remainingDistance) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (state.delivery!.status == DeliveryStatusEnum.accepted.name)
          ButtonAtom(
            buttonSize: ButtonSize.small,
            data: 'Annuler',
            color: Colors.redAccent,
            onTap: () => deliveryTrackingBloc.add(UpdateDeliveryStatusEvent(DeliveryStatusEnum.pending)),
          ),
        const SizedBox(width: 10),
        if (state.delivery!.status == DeliveryStatusEnum.accepted.name) _buildPickedUpButton(deliveryTrackingBloc, remainingDistance),
        if (state.delivery!.status == DeliveryStatusEnum.picked_up.name) _buildDeliveredButton(deliveryTrackingBloc, remainingDistance),
      ],
    );
  }

  Widget _buildPickedUpButton(DeliveryTrackingBloc deliveryTrackingBloc, double remainingDistance) {
    return ButtonAtom(
      buttonSize: ButtonSize.small,
      onTap: remainingDistance < 150 ? () => deliveryTrackingBloc.add(UpdateDeliveryStatusEvent(DeliveryStatusEnum.picked_up)) : null,
      data: 'Colis récupéré',
    );
  }

  Widget _buildDeliveredButton(DeliveryTrackingBloc deliveryTrackingBloc, double remainingDistance) {
    return ButtonAtom(
      buttonSize: ButtonSize.small,
      onTap: remainingDistance < 150 ? () => deliveryTrackingBloc.add(UpdateDeliveryStatusEvent(DeliveryStatusEnum.delivered)) : null,
      data: 'Colis livré',
    );
  }
}
