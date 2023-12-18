import 'package:challenge_delivery_flutter/views/courier/home_screen.dart';
import 'package:challenge_delivery_flutter/views/courier/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:challenge_delivery_flutter/bloc/auth/auth_bloc.dart';

class CourierLayout extends StatefulWidget {
  final int initialIndex;
  const CourierLayout({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<CourierLayout> {
  late int _currentIndex;

  final _pages = [
    const CourierHomeScreen(),
    const CourierProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final authBloc = BlocProvider.of<AuthBloc>(context);

    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Theme.of(context).colorScheme.primary,
        onTap: (index) => setState(() => _currentIndex = index),
        currentIndex: _currentIndex,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _pages[_currentIndex],
      ),
    );
  }
}
