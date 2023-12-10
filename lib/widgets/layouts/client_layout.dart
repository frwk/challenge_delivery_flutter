import 'package:challenge_delivery_flutter/common/app_colors.dart';
import 'package:challenge_delivery_flutter/views/client/dashboard/home_screen.dart';
import 'package:challenge_delivery_flutter/views/client/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:challenge_delivery_flutter/bloc/auth/auth_bloc.dart';

class ClientLayout extends StatefulWidget {
  const ClientLayout({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<ClientLayout> {
  int _currentIndex = 0;

  final _pages = [
    const ClientHomeScreen(),
    const ClientProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final authBloc = BlocProvider.of<AuthBloc>(context);

    return Scaffold(
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(onPressed: () {}, icon: Icon(Icons.home, color: Theme.of(context).colorScheme.secondary)),
            IconButton(onPressed: () {}, icon: Icon(Icons.assignment, color: Theme.of(context).colorScheme.secondary)),
            IconButton(onPressed: () {}, icon: Icon(Icons.person, color: Theme.of(context).colorScheme.secondary)),
            IconButton(onPressed: () {}, icon: Icon(Icons.notifications, color: Theme.of(context).colorScheme.secondary)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/create-order'),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _pages[_currentIndex],
      ),
    );
  }
}
