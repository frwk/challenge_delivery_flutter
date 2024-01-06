import 'package:challenge_delivery_flutter/bloc/auth/auth_bloc.dart';
import 'package:challenge_delivery_flutter/bloc/delivery/delivery_tracking_bloc.dart';
import 'package:challenge_delivery_flutter/bloc/delivery/delivery_tracking_state.dart';
import 'package:challenge_delivery_flutter/enums/delivery_status_enum.dart';
import 'package:challenge_delivery_flutter/enums/role_enum.dart';
import 'package:challenge_delivery_flutter/exceptions/not_found_exception.dart';
import 'package:challenge_delivery_flutter/models/complaint.dart';
import 'package:challenge_delivery_flutter/models/user.dart';
import 'package:challenge_delivery_flutter/services/complaint/complaint_service.dart';
import 'package:challenge_delivery_flutter/views/complaint/complaint_detail_screen_args.dart';
import 'package:challenge_delivery_flutter/widgets/layouts/client_layout.dart';
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
    final authUser = BlocProvider.of<AuthBloc>(context).state.user;

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
                    InfoRow('Adresse de prise en charge:', state.delivery?.pickupAddress ?? 'Chargement...'),
                    const SizedBox(height: 20),
                    InfoRow('Adresse de livraison:', state.delivery?.dropoffAddress ?? 'Chargement...'),
                    if (state.delivery?.status == DeliveryStatusEnum.delivered.name) ...[
                      const Divider(height: 30, thickness: 2),
                      InfoRow('Durée de la livraison:', '${widget.delivery.dropoffDate!.difference(widget.delivery.pickupDate!).inMinutes} minutes'),
                    ],
                    const Divider(height: 30, thickness: 2),
                    ButtonAtom(
                      data: "Retourner à l'accueil",
                      onTap: () => authUser?.role == RoleEnum.courier.name
                          ? Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const CourierLayout()), (route) => false)
                          : Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const ClientLayout()), (route) => false),
                      buttonSize: ButtonSize.small,
                    ),
                    if (state.delivery?.status == DeliveryStatusEnum.delivered.name) ...[
                      const SizedBox(height: 20),
                      ButtonAtom(
                        data: "Contacter le support",
                        buttonSize: ButtonSize.small,
                        onTap: () => _contactSupportAction(context, state.delivery!, authUser!),
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
        const SizedBox(width: 20.0),
        Expanded(
          child: Text(value, style: const TextStyle(fontSize: 16)),
        ),
      ],
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
