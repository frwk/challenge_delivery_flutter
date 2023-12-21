import 'package:challenge_delivery_flutter/components/my_list_tile.dart';
import 'package:flutter/material.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.primary,
      child: Column(
        children: [
        //   Logo
          DrawerHeader(
             child: Icon(
               Icons.delivery_dining,
               size: 72,
               color: Theme.of(context).colorScheme.inversePrimary,
             ),
          ),
         const SizedBox(height: 20),
        //   Dashboard
          MyListTile(text: 'Accueil', icon: Icons.home, onTap: () {
            Navigator.pushNamed(context, '/client/home');
          }),
          const SizedBox(height: 25),
          const MyListTile(text: 'Mes commandes', icon: Icons.assignment),
          const SizedBox(height: 25),
          const MyListTile(text: 'Mes réclamations', icon: Icons.report),
          const SizedBox(height: 25),
          const MyListTile(text: 'Paramètres', icon: Icons.settings),
          const Padding(
            padding: EdgeInsets.only(top: 300.0),
            child: MyListTile(text: 'Deconnexion', icon: Icons.logout),
          ),
        //   Orders

        //   Reclamations

        //   Notifications

        //   Settings

        ],
      ),
    );
  }
}
