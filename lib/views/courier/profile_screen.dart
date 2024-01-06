import 'package:challenge_delivery_flutter/bloc/auth/auth_bloc.dart';
import 'package:challenge_delivery_flutter/enums/courier_status_enum.dart';
import 'package:challenge_delivery_flutter/views/auth/login/login_screen.dart';
import 'package:challenge_delivery_flutter/widgets/layouts/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lite_rolling_switch/lite_rolling_switch.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authBloc = BlocProvider.of<AuthBloc>(context);

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is LogOutAuthState) {
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
        }
      },
      builder: (context, state) {
        if (state is LogOutAuthState) {
          return const Center(child: CircularProgressIndicator());
        }
        return Scaffold(
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
                          '${state.user?.firstName} ${state.user?.lastName}',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.orange[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          state.user!.email,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.orange[700],
                          ),
                        ),
                      ],
                    ),
                    if (authBloc.state.user!.role == 'courier') ...[
                      const Spacer(),
                      LiteRollingSwitch(
                        value: authBloc.state.user!.courier!.status == CourierStatusEnum.available.name,
                        textOn: 'Disponible',
                        textOff: 'Occupé',
                        colorOn: Colors.greenAccent[700]!,
                        colorOff: Colors.redAccent[700]!,
                        iconOn: Icons.done,
                        iconOff: Icons.remove_circle_outline,
                        textSize: 14.2,
                        textOnColor: Colors.white,
                        textOffColor: Colors.white,
                        onTap: () => null,
                        onDoubleTap: () => null,
                        onSwipe: () => null,
                        onChanged: (bool state) {
                          BlocProvider.of<AuthBloc>(context)
                              .add(UpdateCourierStatusEvent(status: state ? CourierStatusEnum.available : CourierStatusEnum.unavailable));
                        },
                      ),
                    ]
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
        );
      },
    );
  }
}
