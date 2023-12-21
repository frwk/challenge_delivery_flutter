import 'package:challenge_delivery_flutter/atoms/button_atom.dart';
import 'package:challenge_delivery_flutter/bloc/auth/auth_bloc.dart';
import 'package:challenge_delivery_flutter/bloc/delivery%20copy/delivery_tracking_bloc.dart';
import 'package:challenge_delivery_flutter/bloc/delivery%20copy/delivery_tracking_event.dart';
import 'package:challenge_delivery_flutter/bloc/delivery%20copy/delivery_tracking_state.dart';
import 'package:challenge_delivery_flutter/views/courier/delivery/delivery_summary_screen.dart';
import 'package:challenge_delivery_flutter/widgets/delivery/delivery_infos.dart';
import 'package:challenge_delivery_flutter/widgets/delivery/delivery_map.dart';
import 'package:challenge_delivery_flutter/widgets/layouts/courier_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class MapDeliveryScreen extends StatefulWidget {
  const MapDeliveryScreen({super.key});

  @override
  _MapDeliveryScreenState createState() => _MapDeliveryScreenState();
}

class _MapDeliveryScreenState extends State<MapDeliveryScreen> with WidgetsBindingObserver {
  late DeliveryTrackingBloc deliveryTrackingBloc;

  @override
  void initState() {
    deliveryTrackingBloc = BlocProvider.of<DeliveryTrackingBloc>(context);
    AuthBloc authBloc = BlocProvider.of<AuthBloc>(context);
    deliveryTrackingBloc.add(StartDeliveryTracking(authBloc.state.user!.courier!));
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      if (!await Geolocator.isLocationServiceEnabled() || !await Permission.location.isGranted) {
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const CourierLayout()), (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DeliveryTrackingBloc, DeliveryTrackingState>(builder: (context, state) {
      if (state.status.isStarted && state.delivery != null) {
        return Scaffold(
          body: Stack(
            children: [
              DeliveryMap(delivery: state.delivery!),
              Positioned(left: 20, right: 20, bottom: 20, child: DeliveryInfos(delivery: state.delivery!))
            ],
          ),
        );
      } else if (state.status.isSuccess) {
        return DeliverySummaryScreen(delivery: state.delivery!);
      } else if (state.status.isError) {
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (state.errorType.isNotFound) ...[
                  const Text('Aucune livraison en cours'),
                  ButtonAtom(
                    onTap: () => Navigator.pushAndRemoveUntil(
                        context, MaterialPageRoute(builder: (context) => const CourierLayout(initialPage: 'requests')), (route) => false),
                    data: 'Voir les demandes',
                  ),
                ] else ...[
                  const Text('Erreur lors du chargement de la livraison'),
                  ButtonAtom(
                    onTap: () => deliveryTrackingBloc.add(StartDeliveryTracking(BlocProvider.of<AuthBloc>(context).state.user!.courier!)),
                    data: 'Réessayer',
                  ),
                ],
              ],
            ),
          ),
        );
      } else {
        return const Center(child: CircularProgressIndicator());
      }
    });
  }
}
