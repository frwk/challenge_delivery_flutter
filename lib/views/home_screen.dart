import 'package:challenge_delivery_flutter/atoms/button_atom.dart';
import 'package:challenge_delivery_flutter/bloc/auth/auth_bloc.dart';
import 'package:challenge_delivery_flutter/components/my_card.dart';
import 'package:challenge_delivery_flutter/enums/role_enum.dart';
import 'package:challenge_delivery_flutter/interfaces/user_stats.dart';
import 'package:challenge_delivery_flutter/services/order/order_service.dart';
import 'package:challenge_delivery_flutter/widgets/error.dart';
import 'package:challenge_delivery_flutter/widgets/layouts/client_layout.dart';
import 'package:challenge_delivery_flutter/widgets/layouts/courier_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
                if (authUser?.role == RoleEnum.client.name) {
                  return await OrderService().getUserStats(state.user!);
                } else {
                  return await OrderService().getCourierStats(state.user!.courier!);
                }
              } catch (e) {
                return Future<UserStats>.error(e.toString());
              }
            }(),
            builder: (context, snapshot) {
              return Column(
                children: <Widget>[
                  _buildTopStack(context),
                  Flexible(
                    child: _buildContent(context, snapshot),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildTopStack(BuildContext context) {
    final authUser = BlocProvider.of<AuthBloc>(context).state.user;
    return Stack(
      children: <Widget>[
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
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 26),
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
    );
  }

  Widget _buildContent(BuildContext context, AsyncSnapshot<UserStats> snapshot) {
    final authUser = BlocProvider.of<AuthBloc>(context).state.user;

    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    } else if (snapshot.hasError || snapshot.data?.totalDeliveries == 0) {
      return ErrorMessage(
        icon: Icons.grid_off_rounded,
        message: 'Aucune statistique à afficher pour le moment',
        actions: [
          ButtonAtom(
            data: 'Voir les demandes',
            color: Theme.of(context).colorScheme.primary,
            icon: Icons.local_shipping,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => authUser?.role == RoleEnum.courier.name
                    ? const CourierLayout(initialPage: 'requests')
                    : const ClientLayout(initialPage: 'requests'),
              ),
            ),
          ),
        ],
      );
    } else {
      return SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                crossAxisSpacing: 0,
                mainAxisSpacing: 0,
                children: <Widget>[
                  _buildStatCard('Nombre de courses', '${snapshot.data!.totalDeliveries}', Icons.directions_car),
                  _buildStatCard('Moyenne des evaluations', '${snapshot.data!.averageRating?.toStringAsFixed(1) ?? 'Aucune'}', Icons.star),
                  _buildStatCard('Distance totale', '${snapshot.data!.totalDistance?.toStringAsFixed(2)} km', Icons.directions_run),
                  _buildStatCard('Durée totale', '${snapshot.data!.totalDuration?.toStringAsFixed(0)} h', Icons.timer),
                ],
              ),
            ),
          ],
        ),
      );
    }
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
