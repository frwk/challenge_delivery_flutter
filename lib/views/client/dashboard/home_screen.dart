import 'package:challenge_delivery_flutter/common/app_colors.dart';
import 'package:challenge_delivery_flutter/components/my_card.dart';
import 'package:challenge_delivery_flutter/themes/light_mode.dart';
import 'package:flutter/material.dart';

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Column(
      children: [
        Stack(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: 350,
              decoration: const BoxDecoration(
                  color: Colors.amber,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                )
              ),
              child:  Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Center(
                      child: Text('Rechercher mes expéditions', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 20.0),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Entrez la référence de votre envoi',
                        hintStyle: const TextStyle(color: Colors.black),
                        prefixIcon: const Icon(Icons.search, color: Colors.black),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide.none
                        ),
                        filled: true,
                        fillColor: Colors.white
                      ),
                    ),
                  ),
                  const SizedBox(height: 30.0),
                ],
              ),
            ),
            Image.asset(
              'assets/img/welcome/welcome_view_2.png',
              color: Colors.white.withOpacity(0.4),
              alignment: Alignment.bottomCenter,
              height: 380,

            ),
            Padding(
              padding: const EdgeInsets.only(left: 45.0),
              child: Image.asset(
                'assets/img/welcome/location_1.png',
                color: Colors.white,
                alignment: Alignment.bottomLeft,
                height: 320,
              ),
            ),
            Image.asset(
              'assets/img/welcome/location_1.png',
              color: Colors.white,
              alignment: Alignment.bottomRight,
              height: 320,
            ),
            Image.asset(
              'assets/img/welcome/welcome_view_1.png',
              alignment: Alignment.bottomCenter,
              // width: MediaQuery.of(context).size.width,
              height: 345,
              // fit: BoxFit.contain,
            ),
          ],
        ),
         Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
           MyCard(child: Column(
             children: [
               Icon(Icons.assignment, color: Theme.of(context).colorScheme.secondary),
               Padding(
                 padding: const EdgeInsets.all(8.0),
                 child: Text('Mes courses', style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
               )
             ],
           )),
           MyCard(
               child: Column(
                 children: [
                   Icon(Icons.assignment, color: Theme.of(context).colorScheme.secondary),
                   Padding(
                     padding: const EdgeInsets.all(8.0),
                     child: Text('Mes courses', style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
                   )
                 ],
               ),

           ),
          ],
        ),
        const SizedBox(height: 35),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            MyCard(child: Column(
              children: [
                Icon(Icons.assignment, color: Theme.of(context).colorScheme.secondary),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Mes courses', style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
                )
              ],
            )),
            MyCard(
              child: Column(
                children: [
                  Icon(Icons.assignment, color: Theme.of(context).colorScheme.secondary),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Mes courses', style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
                  )
                ],

              ),

            ),
          ],
        )

      ],
    )
    );
  }
}
