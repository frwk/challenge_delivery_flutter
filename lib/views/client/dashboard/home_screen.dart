import 'package:challenge_delivery_flutter/bloc/auth/auth_bloc.dart';
import 'package:challenge_delivery_flutter/components/my_card.dart';
import 'package:challenge_delivery_flutter/interfaces/user_stats.dart';
import 'package:challenge_delivery_flutter/services/order/order_service.dart';
import 'package:challenge_delivery_flutter/widgets/error.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  @override
  Widget build(BuildContext context) {
    final authUser = BlocProvider.of<AuthBloc>(context).state.user;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          body: FutureBuilder<UserStats>(
            future: () async {
              try {
                return await OrderService().getUserStats(state.user!);
              } catch (e) {
                return Future<UserStats>.error(e.toString());
              }
            }(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Container(
                  width: double.infinity,
                  child: ErrorMessage(
                    type: ErrorMessageTypeEnum.noResult,
                    message: 'Aucune réclamation en cours',
                  ),
                );
              } else if (snapshot.hasData) {
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: 250,
                            decoration: const BoxDecoration(
                                color: Colors.amber,
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(50),
                                  bottomRight: Radius.circular(50),
                                )),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Center(
                                  child: Text(
                                    'Bienvenue ${authUser?.firstName} ${authUser?.lastName}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineLarge
                                        ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 26),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            bottom: -70,
                            right: 0,
                            child: Image.asset(
                              'assets/img/welcome/welcome_view_2.png',
                              color: Colors.white.withOpacity(0.4),
                              alignment: Alignment.center,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Image.asset(
                              'assets/img/welcome/welcome_view_1.png',
                              alignment: Alignment.bottomCenter,
                              height: 280,
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        child: GridView.count(
                          shrinkWrap: true,
                          crossAxisCount: 2,
                          crossAxisSpacing: 0,
                          mainAxisSpacing: 0,
                          children: <Widget>[
                            _buildStatCard('Nombre de courses', '${snapshot.data!.totalDeliveries} livraisons', Icons.directions_car),
                            _buildStatCard('Moyenne des evaluations', '${snapshot.data!.averageRating?.toStringAsFixed(1)}', Icons.star),
                            _buildStatCard('Distance totale', '${snapshot.data!.totalDistance?.toStringAsFixed(2)} km', Icons.directions_run),
                            _buildStatCard('Durée totale', '${snapshot.data!.totalDuration?.toStringAsFixed(0)} h', Icons.timer),
                          ],
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
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return MyCard(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 30, color: Theme.of(context).colorScheme.secondary),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
