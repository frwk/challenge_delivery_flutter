import 'package:flutter/material.dart';

class LocationListTile extends StatelessWidget {

  final String location;
  final VoidCallback? onTap;

  const LocationListTile({
    super.key,
    required this.location,
    this.onTap
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Container(
          margin: const EdgeInsets.only(top: 8.0),
          color: Colors.grey.withOpacity(0.1),
          child: ListTile(
            onTap: onTap,
            leading: const Icon(Icons.location_on),
            title: Text(location, style: const TextStyle(fontSize: 12),),
          )
      )
    );
  }
}
