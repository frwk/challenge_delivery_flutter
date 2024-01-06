import 'dart:convert';
import 'package:challenge_delivery_flutter/atoms/button_atom.dart';
import 'package:challenge_delivery_flutter/bloc/auth/auth_bloc.dart';
import 'package:challenge_delivery_flutter/bloc/delivery/delivery_tracking_bloc.dart';
import 'package:challenge_delivery_flutter/bloc/delivery/delivery_tracking_event.dart';
import 'package:challenge_delivery_flutter/bloc/delivery/delivery_tracking_state.dart';
import 'package:challenge_delivery_flutter/enums/role_enum.dart';
import 'package:challenge_delivery_flutter/models/delivery.dart';
import 'package:challenge_delivery_flutter/models/user.dart';
import 'package:challenge_delivery_flutter/services/order/order_service.dart';
import 'package:challenge_delivery_flutter/services/user_service.dart';
import 'package:challenge_delivery_flutter/views/courier/delivery/delivery_summary_screen.dart';
import 'package:challenge_delivery_flutter/widgets/delivery/delivery_infos.dart';
import 'package:challenge_delivery_flutter/widgets/delivery/delivery_map.dart';
import 'package:challenge_delivery_flutter/widgets/error.dart';
import 'package:challenge_delivery_flutter/widgets/layouts/courier_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class MapDeliveryScreen extends StatefulWidget {
  final int? deliveryId;
  const MapDeliveryScreen({super.key, this.deliveryId});
  @override
  _MapDeliveryScreenState createState() => _MapDeliveryScreenState();
}

class _MapDeliveryScreenState extends State<MapDeliveryScreen> with WidgetsBindingObserver {
  late DeliveryTrackingBloc deliveryTrackingBloc;
  late User? user;
  late Delivery? delivery;
  bool _init = false;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    if (!_init) {
      deliveryTrackingBloc = BlocProvider.of<DeliveryTrackingBloc>(context);
      user = BlocProvider.of<AuthBloc>(context).state.user;
      if (user?.role == RoleEnum.client.name) {
        Delivery delivery = ModalRoute.of(context)!.settings.arguments as Delivery;
        deliveryTrackingBloc.add(StartDeliveryTracking(user: user!, delivery: delivery));
      } else {
        deliveryTrackingBloc.add(StartDeliveryTracking(user: user!));
      }
      _init = true;
    }
  }

  @override
  void dispose() {
    if (user?.role == RoleEnum.courier.name) {
      Geolocator.getCurrentPosition().then((Position position) {
        userService.updateCourier(user!.courier!.copyWith(latitude: position.latitude, longitude: position.longitude));
      });
    }
    deliveryTrackingBloc.add(StopDeliveryTracking());
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
          body: RefreshIndicator(
            onRefresh: () async {
              if (user?.role == RoleEnum.client.name) {
                Delivery delivery = ModalRoute.of(context)!.settings.arguments as Delivery;
                deliveryTrackingBloc.add(StartDeliveryTracking(user: user!, delivery: delivery));
              } else {
                deliveryTrackingBloc.add(StartDeliveryTracking(user: user!));
              }
            },
            child: state.errorType.isNotFound
                ? ErrorMessage(
                    icon: Icons.search_off,
                    message: 'Aucune livraison en cours',
                    actions: [
                      ButtonAtom(
                        data: 'Voir les demandes',
                        color: Theme.of(context).colorScheme.primary,
                        icon: Icons.local_shipping,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CourierLayout(initialPage: 'requests'))),
                      )
                    ],
                  )
                : ErrorMessage(
                    icon: Icons.error,
                    message: 'Erreur lors du chargement de la livraison',
                    actions: [
                      ButtonAtom(
                        data: 'Rafraîchir',
                        color: Theme.of(context).colorScheme.primary,
                        icon: Icons.refresh,
                        onTap: () => user?.role == RoleEnum.client.name
                            ? deliveryTrackingBloc.add(StartDeliveryTracking(user: user!, delivery: delivery!))
                            : deliveryTrackingBloc.add(StartDeliveryTracking(user: user!)),
                      )
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
