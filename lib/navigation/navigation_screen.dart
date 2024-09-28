import 'package:buybit/screens/home_screen.dart';
import 'package:buybit/screens/market_screen.dart';
import 'package:buybit/navigation/navigation_bottom_bar_screen.dart';
import 'package:buybit/screens/order_screen.dart';
import 'package:buybit/screens/wallet_screen.dart';
import 'package:flutter/material.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  _NavigationScreenState createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    HomeScreen(),
    MarketScreen(),
    OrderScreen(),
    WalletScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBottomBarScreen(
        selectedIndex: _selectedIndex,
        onItemSelected: _onItemTapped,
      ),
    );
  }
}
