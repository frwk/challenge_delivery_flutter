import 'package:challenge_delivery_flutter/atoms/button_atom.dart';
import 'package:challenge_delivery_flutter/bloc/auth/auth_bloc.dart';
import 'package:challenge_delivery_flutter/bloc/delivery/delivery_tracking_bloc.dart';
import 'package:challenge_delivery_flutter/bloc/delivery/delivery_tracking_event.dart';
import 'package:challenge_delivery_flutter/bloc/delivery/delivery_tracking_state.dart';
import 'package:challenge_delivery_flutter/enums/delivery_status_enum.dart';
import 'package:challenge_delivery_flutter/enums/role_enum.dart';
import 'package:challenge_delivery_flutter/exceptions/not_found_exception.dart';
import 'package:challenge_delivery_flutter/helpers/url_launcher.dart';
import 'package:challenge_delivery_flutter/models/complaint.dart';
import 'package:challenge_delivery_flutter/models/delivery.dart';
import 'package:challenge_delivery_flutter/models/user.dart';
import 'package:challenge_delivery_flutter/services/complaint/complaint_service.dart';
import 'package:challenge_delivery_flutter/views/complaint/complaint_detail_screen_args.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

import '../../helpers/url_launcher.dart';

class DeliveryInfos extends StatelessWidget {
  final Delivery delivery;

  const DeliveryInfos({super.key, required this.delivery});

  @override
  Widget build(BuildContext context) {
    final user = BlocProvider.of<AuthBloc>(context).state.user;
    return Container(
      padding: const EdgeInsets.all(15.0),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.0),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(.5), blurRadius: 7, spreadRadius: 5)]),
      child: Column(
        children: [
          BlocBuilder<DeliveryTrackingBloc, DeliveryTrackingState>(builder: (context, state) {
            final deliveryTrackingBloc = BlocProvider.of<DeliveryTrackingBloc>(context);
            if (state.status.isStarted && state.delivery != null) {
              if (user?.role == RoleEnum.client.name) {
                return Column(
                  children: [
                    _buildAddressRow(deliveryTrackingBloc, delivery),
                    if (delivery.courier != null) ...[
                      const Divider(),
                      _buildUserInfoRow(delivery.courier!.user!),
                    ],
                    _buildDeliveryInfoRow(deliveryTrackingBloc, delivery),
                    _buildActionButtonRow(deliveryTrackingBloc, state, user!, context),
                  ],
                );
              } else {
                if (state.location == null) {
                  return const Center(child: CircularProgressIndicator());
                }
                double remainingDistance = _calculateRemainingDistance(state, delivery);
                return Column(
                  children: [
                    _buildAddressRow(deliveryTrackingBloc, delivery),
                    const Divider(),
                    _buildUserInfoRow(deliveryTrackingBloc.client),
                    _buildActionButtonRow(deliveryTrackingBloc, state, user!, context, remainingDistance),
                  ],
                );
              }
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
        const SizedBox(width: 10.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Adresse', style: TextStyle(fontWeight: FontWeight.w500)),
              Text(
                delivery.status == DeliveryStatusEnum.picked_up.name || delivery.status == DeliveryStatusEnum.pending.name
                    ? delivery.dropoffAddress!
                    : delivery.pickupAddress!,
                style: const TextStyle(fontWeight: FontWeight.w500),
                softWrap: true,
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildUserInfoRow(User user) {
    return Row(
      children: [
        Text("${user.firstName} ${user.lastName}"),
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

  Widget _buildDeliveryInfoRow(DeliveryTrackingBloc deliveryTrackingBloc, Delivery delivery) {
    String displayedText = '';
    if ((delivery.status == DeliveryStatusEnum.pending.name)) {
      displayedText = 'Recherche d\'un livreur en cours...';
    } else if (delivery.status == DeliveryStatusEnum.accepted.name) {
      displayedText = 'Récupération du colis en cours';
    } else if (delivery.status == DeliveryStatusEnum.picked_up.name) {
      displayedText = 'Livraison du colis en cours';
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(displayedText, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16.0)),
              if ((delivery.status == DeliveryStatusEnum.pending.name)) ...[
                const SizedBox(height: 10.0),
                const CircularProgressIndicator(),
              ]
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtonRow(DeliveryTrackingBloc deliveryTrackingBloc, DeliveryTrackingState state, User user, BuildContext context,
      [double? remainingDistance]) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (user.role == RoleEnum.courier.name && state.delivery!.status == DeliveryStatusEnum.accepted.name ||
            user.role == RoleEnum.client.name && state.delivery!.status == DeliveryStatusEnum.pending.name) ...[
          ButtonAtom(
            buttonSize: ButtonSize.small,
            data: 'Annuler',
            color: Colors.redAccent,
            onTap: () => deliveryTrackingBloc.add(UpdateDeliveryStatusEvent(
                state.delivery!.status == DeliveryStatusEnum.accepted.name ? DeliveryStatusEnum.pending : DeliveryStatusEnum.cancelled)),
          ),
          const SizedBox(width: 10),
        ],
        if (remainingDistance != null) ...[
          if (state.delivery!.status == DeliveryStatusEnum.accepted.name) _buildPickedUpButton(deliveryTrackingBloc, remainingDistance),
          if (state.delivery!.status == DeliveryStatusEnum.picked_up.name) _buildDeliveredButton(deliveryTrackingBloc, remainingDistance),
          const SizedBox(width: 10),
        ],
        _buildSupportButton(deliveryTrackingBloc, user, context),
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

  Widget _buildSupportButton(DeliveryTrackingBloc deliveryTrackingBloc, User user, BuildContext context) {
    return ButtonAtom(
      buttonSize: ButtonSize.small,
      onTap: () => _contactSupportAction(context, delivery, user),
      data: 'Support',
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
}
