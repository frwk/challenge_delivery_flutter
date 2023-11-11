import 'package:challenge_delivery_flutter/enums/role_enum.dart';
import 'package:challenge_delivery_flutter/views/auth/register/register_screen.dart';
import 'package:flutter/material.dart';

class RegisterFirstStep extends StatelessWidget {
  const RegisterFirstStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(alignment: Alignment.center, child: const Text('Annuler', style: TextStyle(color: Colors.white, fontSize: 15))),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        leadingWidth: 70,
        title: const Text('Créer un compte', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Qui êtes-vous ?', style: TextStyle(fontSize: 25, color: Theme.of(context).colorScheme.primary)),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: ElevatedButton(
                        onPressed: () =>
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterClientScreen(role: RoleEnum.client))),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.horizontal(left: Radius.circular(30), right: Radius.circular(30)),
                          ),
                          elevation: 5,
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.person, size: 50),
                              Text(
                                'Client',
                                style: TextStyle(fontSize: 30),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 75),
                    Center(
                      child: ElevatedButton(
                        onPressed: () =>
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterClientScreen(role: RoleEnum.courier))),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.horizontal(left: Radius.circular(30), right: Radius.circular(30)),
                          ),
                          elevation: 5,
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.delivery_dining, size: 50),
                              Text(
                                'Livreur',
                                style: TextStyle(fontSize: 30),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
