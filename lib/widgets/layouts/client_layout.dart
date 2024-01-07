import 'package:challenge_delivery_flutter/common/app_colors.dart';
import 'package:challenge_delivery_flutter/state/app_state.dart';
import 'package:challenge_delivery_flutter/views/complaint/complaint_listing_screen.dart';
import 'package:challenge_delivery_flutter/views/courier/profile_screen.dart';
import 'package:challenge_delivery_flutter/views/home_screen.dart';
import 'package:flutter/material.dart';

class ClientLayout extends StatefulWidget {
  final String initialPage;
  const ClientLayout({super.key, this.initialPage = 'home'});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<ClientLayout> {
  late String _currentPageKey;

  final Map<String, Widget> _pages = {
    'home': const HomeScreen(),
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
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Plaintes'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/create-order'),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterFloat,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _pages[_currentPageKey]!,
      ),
    );
  }
}
