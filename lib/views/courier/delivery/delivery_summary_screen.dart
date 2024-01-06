import 'package:challenge_delivery_flutter/bloc/auth/auth_bloc.dart';
import 'package:challenge_delivery_flutter/bloc/delivery/delivery_tracking_bloc.dart';
import 'package:challenge_delivery_flutter/bloc/delivery/delivery_tracking_state.dart';
import 'package:challenge_delivery_flutter/enums/delivery_status_enum.dart';
import 'package:challenge_delivery_flutter/enums/role_enum.dart';
import 'package:challenge_delivery_flutter/exceptions/not_found_exception.dart';
import 'package:challenge_delivery_flutter/models/complaint.dart';
import 'package:challenge_delivery_flutter/models/user.dart';
import 'package:challenge_delivery_flutter/services/complaint/complaint_service.dart';
import 'package:challenge_delivery_flutter/services/order/order_service.dart';
import 'package:challenge_delivery_flutter/views/complaint/complaint_detail_screen_args.dart';
import 'package:challenge_delivery_flutter/widgets/layouts/client_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:challenge_delivery_flutter/atoms/button_atom.dart';
import 'package:challenge_delivery_flutter/models/delivery.dart';
import 'package:challenge_delivery_flutter/widgets/layouts/courier_layout.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

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
  double _currentNotation = 3;
  User? authUser;

  @override
  void initState() {
    super.initState();
    authUser = BlocProvider.of<AuthBloc>(context).state.user;
  }

  @override
  void dispose() {
    if (authUser?.role == RoleEnum.client.name) {
      updateNotation(_currentNotation).then((_) {}).catchError((error) {});
    }
    super.dispose();
  }

  Future<void> updateNotation(double rating) async {
    await orderService.updateDelivery(widget.delivery.copyWith(notation: rating.toInt()));
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
                    const SizedBox(height: 20),
                    if (authUser?.role == RoleEnum.client.name && widget.delivery.status == DeliveryStatusEnum.delivered.name) ...[
                      const Text(
                        'Notez la livraison',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      RatingBar.builder(
                        initialRating: _currentNotation,
                        itemCount: 5,
                        itemBuilder: (context, index) {
                          switch (index) {
                            case 0:
                              return Icon(
                                Icons.sentiment_very_dissatisfied,
                                color: Colors.red,
                              );
                            case 1:
                              return Icon(
                                Icons.sentiment_dissatisfied,
                                color: Colors.redAccent,
                              );
                            case 2:
                              return Icon(
                                Icons.sentiment_neutral,
                                color: Colors.amber,
                              );
                            case 3:
                              return Icon(
                                Icons.sentiment_satisfied,
                                color: Colors.lightGreen,
                              );
                            case 4:
                              return Icon(
                                Icons.sentiment_very_satisfied,
                                color: Colors.green,
                              );
                            default:
                              return const Icon(
                                Icons.sentiment_neutral,
                                color: Colors.amber,
                              );
                          }
                        },
                        onRatingUpdate: (notation) {
                          setState(() {
                            _currentNotation = notation;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ButtonAtom(
                          data: "Accueil",
                          onTap: () => authUser?.role == RoleEnum.courier.name
                              ? Navigator.pushAndRemoveUntil(
                                  context, MaterialPageRoute(builder: (context) => const CourierLayout()), (route) => false)
                              : Navigator.pushAndRemoveUntil(
                                  context, MaterialPageRoute(builder: (context) => const ClientLayout()), (route) => false),
                        ),
                        if (state.delivery?.status == DeliveryStatusEnum.delivered.name) ...[
                          const SizedBox(width: 20),
                          ButtonAtom(
                            data: "Support",
                            onTap: () => _contactSupportAction(context, state.delivery!, authUser!),
                          ),
                        ],
                      ],
                    ),
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
