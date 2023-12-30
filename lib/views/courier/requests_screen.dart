import 'package:challenge_delivery_flutter/atoms/landing_title_atom.dart';
import 'package:challenge_delivery_flutter/bloc/auth/auth_bloc.dart';
import 'package:challenge_delivery_flutter/common/app_colors.dart';
import 'package:challenge_delivery_flutter/enums/role_enum.dart';
import 'package:challenge_delivery_flutter/models/delivery.dart';
import 'package:challenge_delivery_flutter/services/order/order_service.dart';
import 'package:challenge_delivery_flutter/widgets/deliveries_list.dart';
import 'package:challenge_delivery_flutter/widgets/layouts/courier_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CourierRequestsScreen extends StatelessWidget {
  const CourierRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state.user?.role == RoleEnum.courier.name && state.user?.courier != null) {
          return FutureBuilder<Delivery?>(
            future: orderService.getCurrentCourierDelivery(state.user!.courier!),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Column(
                  children: [
                    const LandingTitleAtom(title: 'Demandes de livraison', titleColor: AppColors.primary),
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
                          return const CircularProgressIndicator();
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
                return Column(
                  children: [
                    const LandingTitleAtom(title: 'Livraison en cours', titleColor: AppColors.primary),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ListTile(
                          tileColor: Theme.of(context).colorScheme.primary,
                          title: const Text('Livraison en cours'),
                          subtitle: Text('${delivery.client?.firstName} ${delivery.client?.lastName}'),
                          trailing: const Icon(Icons.arrow_forward),
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const CourierLayout(
                                        initialPage: 'map',
                                      ))),
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                return const Text('Pas de livraison en cours');
              }
            },
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
