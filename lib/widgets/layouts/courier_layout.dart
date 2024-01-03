import 'package:challenge_delivery_flutter/state/app_state.dart';
import 'package:challenge_delivery_flutter/views/complaint/complaint_listing_screen.dart';
import 'package:challenge_delivery_flutter/views/courier/dashboard_screen.dart';
import 'package:challenge_delivery_flutter/views/courier/delivery/map_delivery_screen.dart';
import 'package:challenge_delivery_flutter/views/courier/profile_screen.dart';
import 'package:challenge_delivery_flutter/views/courier/requests_screen.dart';
import 'package:flutter/material.dart';

class CourierLayout extends StatefulWidget {
  final String initialPage;
  const CourierLayout({super.key, this.initialPage = 'home'});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<CourierLayout> {
  late String _currentPageKey;

  final Map<String, Widget> _pages = {
    'home': const CourierDashboardScreen(),
    'requests': const CourierRequestsScreen(),
    'map': const MapDeliveryScreen(),
    'complaints': const ComplaintListingScreen(),
    'profile': const CourierProfileScreen(),
  };

  @override
  void initState() {
    super.initState();
    _currentPageKey = _pages.containsKey(widget.initialPage) ? widget.initialPage : 'home';
    AppState.currentPageKey = _currentPageKey;
  }

  void _selectPage(String pageKey) {
    if (_pages.containsKey(pageKey)) {
      setState(() {
        _currentPageKey = pageKey;
        AppState.currentPageKey = pageKey;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        unselectedItemColor: Colors.grey,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        onTap: (index) {
          String pageKey = _pages.keys.elementAt(index);
          _selectPage(pageKey);
        },
        currentIndex: _pages.keys.toList().indexOf(_currentPageKey),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.local_shipping), label: 'Demandes'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Suivi'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Plaintes'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _pages[_currentPageKey]!,
      ),
    );
  }
}
