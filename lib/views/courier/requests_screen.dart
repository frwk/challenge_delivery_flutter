import 'dart:convert';

import 'package:challenge_delivery_flutter/atoms/button_atom.dart';
import 'package:challenge_delivery_flutter/bloc/auth/auth_bloc.dart';
import 'package:challenge_delivery_flutter/enums/courier_status_enum.dart';
import 'package:challenge_delivery_flutter/enums/role_enum.dart';
import 'package:challenge_delivery_flutter/models/delivery.dart';
import 'package:challenge_delivery_flutter/services/order/order_service.dart';
import 'package:challenge_delivery_flutter/services/user_service.dart';
import 'package:challenge_delivery_flutter/widgets/deliveries_list.dart';
import 'package:challenge_delivery_flutter/widgets/error.dart';
import 'package:challenge_delivery_flutter/widgets/layouts/app_bar.dart';
import 'package:challenge_delivery_flutter/widgets/layouts/courier_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CourierRequestsScreen extends StatelessWidget {
  const CourierRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(
        title: 'Demandes de livraison',
        hasBackArrow: false,
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state.user?.role == RoleEnum.courier.name && state.user?.courier != null) {
            if (state.user?.courier?.status == CourierStatusEnum.unavailable.name) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: ErrorMessage(
                  icon: Icons.do_not_disturb,
                  message: 'Veuillez vous marquer comme disponible pour voir et recevoir des demandes de livraison',
                  actions: [
                    ButtonAtom(
                      data: 'Je suis disponible',
                      color: Colors.green,
                      icon: Icons.where_to_vote,
                      onTap: () async {
                        BlocProvider.of<AuthBloc>(context).add(UpdateCourierStatusEvent(status: CourierStatusEnum.available));
                      },
                    )
                  ],
                ),
              );
            }
            return FutureBuilder<Delivery?>(
              future: orderService.getCurrentCourierDelivery(state.user!.courier!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: const CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Column(
                    children: [
                      FutureBuilder<List<Delivery>>(
                        future: () async {
                          try {
                            return await OrderService().getNearbyDeliveries(state.user!.courier!);
                          } catch (e) {
                            return Future<List<Delivery>>.error(e.toString());
                          }
                        }(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Text('Erreur: ${snapshot.error}');
                          } else if (snapshot.hasData) {
                            return Flexible(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: DeliveriesList(deliveries: snapshot.data ?? []),
                              ),
                            );
                          } else {
                            return const Text('Aucune livraison à effectuer autour de vous');
                          }
                        },
                      ),
                    ],
                  );
                } else if (snapshot.hasData) {
                  final delivery = snapshot.data!;
                  return ErrorMessage(
                    icon: Icons.search_off,
                    message: 'Vous avez déjà une livraison en cours',
                    actions: [
                      ButtonAtom(
                        data: 'Suivre la livraison',
                        color: Theme.of(context).colorScheme.primary,
                        icon: Icons.arrow_forward,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CourierLayout(
                              initialPage: 'map',
                            ),
                          ),
                        ),
                      )
                    ],
                  );
                } else {
                  return ErrorMessage(
                    icon: Icons.search_off,
                    message: 'Aucune demande de livraison',
                    actions: [
                      ButtonAtom(
                        data: 'Rafrachir',
                        color: Theme.of(context).colorScheme.primary,
                        icon: Icons.refresh,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CourierLayout(
                                initialPage: 'map',
                              ),
                            ),
                          );
                        },
                      )
                    ],
                  );
                }
              },
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
