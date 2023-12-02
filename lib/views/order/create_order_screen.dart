import 'package:challenge_delivery_flutter/atoms/button_atom.dart';
import 'package:challenge_delivery_flutter/components/input_component.dart';
import 'package:challenge_delivery_flutter/components/my_drawer.dart';
import 'package:flutter/material.dart';

class CreateOrderScreen extends StatelessWidget {
  const CreateOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              color: Colors.black,
              onPressed: () => Navigator.pop(context),
            ),
            title: const Center(
              child: Text(
                'Nouvelle commande',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            titleSpacing: 10,
            actions: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: IconButton(
                  icon: const Icon(Icons.notifications),
                  color: Colors.black,
                  onPressed: () => {},
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 25.0),
              child: const InputComponent(
                label: 'Adresse de départ',
                labelSize: 12,
                labelColor: Colors.grey,
                placeholder: 'Entrez votre adresse de départ',
              ),
            ),
            const SizedBox(height: 10),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 25.0),
              child: const InputComponent(
                label: 'Adresse de destination',
                labelSize: 12,
                labelColor: Colors.grey,
                placeholder: 'Entrez votre adresse de destination',
              ),
            ),
            const SizedBox(height: 30),
            Divider(
              color: Colors.grey.withOpacity(0.5),
              indent: 60,
              endIndent: 60,
              thickness: 1,
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    margin: const EdgeInsets.only(left: 25.0, right: 2),
                    child: const InputComponent(
                      label: 'Type de colis',
                      labelSize: 12,
                      labelColor: Colors.grey,
                      placeholder: 'Quel type de colis ?',
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    margin: const EdgeInsets.only(right: 25.0),
                    child: const InputComponent(
                      label: 'Poids',
                      labelSize: 12,
                      labelColor: Colors.grey,
                      placeholder: 'En kg',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 25.0),
              child: ButtonAtom(data: 'Suivant'),
            )
          ],
        ),
      ),
    );
  }
}
