import 'package:challenge_delivery_flutter/bloc/auth/auth_bloc.dart';
import 'package:challenge_delivery_flutter/views/auth/login/login_screen.dart';
import 'package:challenge_delivery_flutter/widgets/layouts/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CourierProfileScreen extends StatelessWidget {
  const CourierProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authBloc = BlocProvider.of<AuthBloc>(context);

    return BlocListener<AuthBloc, AuthState>(
        listener: (context, state) async {
          if (state is LogOutAuthState) {
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
          }
        },
        child: Scaffold(
          appBar: const MyAppBar(title: 'Profil', hasBackArrow: false),
          body: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${authBloc.state.user!.firstName} ${authBloc.state.user!.lastName}',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.orange[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          authBloc.state.user!.email,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.orange[700],
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.history, color: Colors.orange[600]),
                        title: const Text('Historique des commandes'),
                        onTap: () => Navigator.pushNamed(context, '/history'),
                      ),
                      ListTile(
                        leading: Icon(Icons.edit, color: Colors.orange[600]),
                        title: const Text('Modifier le profil'),
                        onTap: () => Navigator.pushNamed(context, '/edit-profile'),
                      ),
                      ListTile(
                        leading: Icon(Icons.lock_outline, color: Colors.orange[600]),
                        title: const Text('Changer le mot de passe'),
                        onTap: () => Navigator.pushNamed(context, '/change-password'),
                      ),
                      ListTile(
                          leading: Icon(Icons.logout, color: Colors.orange[600]),
                          title: const Text('Déconnexion'),
                          onTap: () => authBloc.add(LogOutEvent())),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
