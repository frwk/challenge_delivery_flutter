import 'package:challenge_delivery_flutter/models/delivery.dart';
import 'package:challenge_delivery_flutter/views/courier/delivery/delivery_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:challenge_delivery_flutter/helpers/secure_storage.dart';

class DeliveriesList extends StatefulWidget {
  final List<Delivery> deliveries;

  const DeliveriesList({super.key, required this.deliveries});

  @override
  State<DeliveriesList> createState() => _DeliveriesListState();
}

class _DeliveriesListState extends State<DeliveriesList> {
  late List<Delivery> sortedDeliveries;
  String sortOption = 'ascending';
  final storage = SecureStorage();
  bool isLoading = true;

  Future<void> initDeliveries() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });
    storage.delete('refused_deliveries');
    sortedDeliveries = List.from(widget.deliveries);
    List<String> refusedIDs = await storage.getRefusedDeliveries();
    if (!mounted) return;
    setState(() {
      sortedDeliveries = sortedDeliveries.where((delivery) {
        return !refusedIDs.contains(delivery.id.toString());
      }).toList();
      _sortDeliveries();
      isLoading = false;
    });
  }

  Future<void> onDeliveryRefused(String id) async {
    setState(() {
      sortedDeliveries = sortedDeliveries.where((delivery) => delivery.id.toString() != id).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    initDeliveries();
  }

  void _sortDeliveries() {
    if (sortOption == 'ascending') {
      sortedDeliveries.sort((a, b) => (a.distanceToPickup ?? 0).compareTo(b.distanceToPickup ?? 0));
    } else {
      sortedDeliveries.sort((a, b) => (b.distanceToPickup ?? 0).compareTo(a.distanceToPickup ?? 0));
    }
  }

  final List<Map<String, String>> sortOptions = [
    {'value': 'ascending', 'label': 'Distance du point de départ (croissant)'},
    {'value': 'descending', 'label': 'Distance du point de départ (décroissant)'},
  ];

  @override
  Widget build(BuildContext context) {
    if (widget.deliveries.isEmpty) {
      return const Center(
        child: Text('Aucune livraison à effectuer autour de vous'),
      );
    }
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Column(
      children: [
        DropdownButton<String>(
          value: sortOption,
          items: sortOptions.map<DropdownMenuItem<String>>((option) {
            return DropdownMenuItem<String>(
              value: option['value'],
              child: Text(
                option['label']!,
                style: const TextStyle(fontSize: 14),
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              sortOption = newValue!;
              _sortDeliveries();
            });
          },
        ),
        Expanded(
          child: ListView.builder(
            itemCount: sortedDeliveries.length,
            itemBuilder: (context, index) {
              final delivery = sortedDeliveries[index];
              return Card(
                child: ListTile(
                  tileColor: Theme.of(context).colorScheme.primary,
                  title: Row(
                    children: [Text('Livraison à ${delivery.distanceToPickup} mètres')],
                  ),
                  subtitle: Text('${delivery.client?.firstName} ${delivery.client?.lastName}'),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DeliveryDetailsScreen(delivery: delivery, onDeliveryRefused: onDeliveryRefused),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
