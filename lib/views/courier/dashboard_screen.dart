import 'package:challenge_delivery_flutter/atoms/button_atom.dart';
import 'package:challenge_delivery_flutter/atoms/landing_title_atom.dart';
import 'package:challenge_delivery_flutter/bloc/auth/auth_bloc.dart';
import 'package:challenge_delivery_flutter/enums/role_enum.dart';
import 'package:challenge_delivery_flutter/interfaces/courier_stats.dart';
import 'package:challenge_delivery_flutter/services/order/order_service.dart';
import 'package:challenge_delivery_flutter/widgets/layouts/courier_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CourierDashboardScreen extends StatelessWidget {
  const CourierDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state.user?.role == RoleEnum.courier.name && state.user?.courier != null) {
          return Column(
            children: [
              LandingTitleAtom(
                title: 'Bienvenue',
                titleColor: Theme.of(context).colorScheme.primary,
                subtitle: state.user?.firstName,
                subtitleColor: Theme.of(context).colorScheme.secondary,
              ),
              Expanded(
                child: FutureBuilder<CourierStats>(
                  future: () async {
                    try {
                      return await OrderService().getCourierStats(state.user!.courier!);
                    } catch (e) {
                      return Future<CourierStats>.error(e.toString());
                    }
                  }(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          margin: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.orangeAccent[100],
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.grid_off_rounded,
                                color: Colors.orangeAccent[700],
                                size: 50,
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'Aucune commande effectuée pour le moment!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "Livrez dés à présent votre premier colis pour afficher des statistiques sur votre activité.",
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),
                              ButtonAtom(
                                data: 'Voir les demandes',
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => CourierLayout(initialPage: 'requests')),
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    } else if (snapshot.hasData) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Card(
                              child: ListTile(
                                leading: const Icon(Icons.local_shipping),
                                title: const Text('Total des livraisons effectuées'),
                                subtitle: Text('${snapshot.data!.totalDeliveries} livraisons'),
                              ),
                            ),
                            Card(
                              child: ListTile(
                                leading: const Icon(Icons.map),
                                title: const Text('Distance totale parcourue'),
                                subtitle: Text('${snapshot.data!.totalDistance?.toStringAsFixed(2)} mètres'),
                              ),
                            ),
                            Card(
                              child: ListTile(
                                leading: const Icon(Icons.star),
                                title: const Text('Note moyenne'),
                                subtitle: Text('${snapshot.data!.averageRating?.toStringAsFixed(1)}'),
                              ),
                            ),
                            Card(
                              child: ListTile(
                                leading: const Icon(Icons.timer),
                                title: const Text('Temps total passé'),
                                subtitle: Text('${snapshot.data!.totalDuration?.toStringAsFixed(2)} minutes'),
                              ),
                            ),
                          ],
                        ),
                      );
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ),
            ],
          );
        } else if (state is FailureAuthState) {
          return Center(
            child: Text(state.error),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
