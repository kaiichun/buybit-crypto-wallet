import 'package:flutter/material.dart';

class NavigationBottomBarScreen extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const NavigationBottomBarScreen(
      {required this.selectedIndex, required this.onItemSelected, super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.show_chart),
          label: 'Market',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.airplane_ticket_outlined),
          label: 'Order',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_balance_wallet),
          label: 'Wallet',
        ),
      ],
      currentIndex: selectedIndex,
      selectedItemColor: Colors.purple,
      unselectedItemColor: Colors.black,
      onTap: onItemSelected,
    );
  }
}
