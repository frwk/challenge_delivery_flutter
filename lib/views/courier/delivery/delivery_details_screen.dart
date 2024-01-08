import 'package:challenge_delivery_flutter/bloc/auth/auth_bloc.dart';
import 'package:challenge_delivery_flutter/components/my_card.dart';
import 'package:challenge_delivery_flutter/enums/delivery_status_enum.dart';
import 'package:challenge_delivery_flutter/enums/role_enum.dart';
import 'package:challenge_delivery_flutter/helpers/secure_storage.dart';
import 'package:challenge_delivery_flutter/widgets/layouts/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:challenge_delivery_flutter/models/delivery.dart';

class MenuAction {
  final String title;
  final VoidCallback action;

  MenuAction({required this.title, required this.action});
}

class DeliveryDetailsScreen extends StatefulWidget {
  final Delivery delivery;
  final Future<void> Function(String)? onDeliveryRefused;
  final List<Widget>? actionsButtons;
  final List<MenuAction>? menuActions;

  const DeliveryDetailsScreen({super.key, required this.delivery, this.onDeliveryRefused, this.actionsButtons, this.menuActions});

  @override
  State<DeliveryDetailsScreen> createState() => _DeliveryDetailsScreenState();
}

class _DeliveryDetailsScreenState extends State<DeliveryDetailsScreen> {
  final storage = SecureStorage();
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

    return Scaffold(
      appBar: MyAppBar(
        title: 'Détails de la Livraison #${widget.delivery.id}',
        actions: widget.menuActions != null
            ? <Widget>[
                PopupMenuButton<MenuAction>(
                  iconColor: Colors.white,
                  onSelected: (MenuAction action) => action.action(),
                  itemBuilder: (BuildContext context) {
                    return widget.menuActions!.map((MenuAction action) {
                      return PopupMenuItem<MenuAction>(
                        value: action,
                        child: Text(action.title),
                      );
                    }).toList();
                  },
                ),
              ]
            : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            authUser?.role == RoleEnum.client.name ? _buildSectionHeader('Informations du Livreur') : _buildSectionHeader('Informations du Client'),
            authUser?.role == RoleEnum.client.name
                ? _buildCard(
                    Icons.person,
                    'Nom complet',
                    widget.delivery.courier != null
                        ? '${widget.delivery.courier?.user?.firstName} ${widget.delivery.courier?.user?.lastName}'
                        : 'Aucun livreur affecté')
                : _buildCard(Icons.person, 'Nom complet', '${widget.delivery.client?.firstName} ${widget.delivery.client?.lastName}'),
            _buildSectionHeader('Détails de la Livraison'),
            _buildCard(
              Icons.info_outline,
              'Statut actuel',
              _getStatusText(widget.delivery.status),
            ),
            _buildCard(Icons.location_on, 'Adresse de départ', widget.delivery.pickupAddress ?? 'Inconnue'),
            _buildCard(Icons.home, 'Adresse de livraison', widget.delivery.dropoffAddress ?? 'Inconnue'),
            _buildCard(Icons.calendar_today, 'Date de la demande',
                DateFormat('dd/MM/yyyy à HH\'h\'mm').format(widget.delivery.pickupDate?.toLocal() ?? DateTime.now())),
            if (authUser?.role == RoleEnum.courier.name) ...[
              _buildCard(Icons.map, 'Distance à parcourir', '${widget.delivery.distance} mètres'),
              _buildCard(Icons.directions_walk, 'Distance du point de départ', '${widget.delivery.distanceToPickup} mètres'),
            ] else if (authUser?.role == RoleEnum.client.name) ...[
              _buildCard(Icons.pin, 'Code de confirmation', '${widget.delivery.confirmationCode}'),
            ],
            const SizedBox(height: 20),
            if (widget.actionsButtons != null) _buildActionsRow(widget.actionsButtons!),
          ],
        ),
      ),
    );
  }

  String _getStatusText(String? status) {
    if (status == DeliveryStatusEnum.pending.name) return 'Recherche d\'un livreur';
    if (status == DeliveryStatusEnum.accepted.name) return 'Colis en cours de récupération';
    if (status == DeliveryStatusEnum.picked_up.name) return 'Colis récupéré';
    if (status == DeliveryStatusEnum.delivered.name) return 'Livré';
    if (status == DeliveryStatusEnum.cancelled.name) return 'Annulé';
    return 'Inconnu';
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.secondary),
      ),
    );
  }

  Widget _buildCard(IconData icon, String title, String subtitle) {
    return MyCard(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
      ),
    );
  }

  Widget _buildActionsRow(List<Widget> actions) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: actions.map((action) => Expanded(child: action)).toList(),
    );
  }
}
