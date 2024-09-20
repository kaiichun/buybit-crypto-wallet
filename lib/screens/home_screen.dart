import 'package:buybit/data/service/auth_service.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  _HomeScreenState createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  void _logout() {
    _authService.logout();
    // After logout, navigate to the login screen or show a message
    Navigator.of(context).pushReplacementNamed(
        '/login'); // Replace with your actual login screen route
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 58, 166, 254),
        title: const Row(
          children: [
            Icon(Icons.currency_bitcoin, color: Colors.white),
            SizedBox(width: 4),
            Text(
              'BuyBit',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout, // Logout action
            tooltip: 'Logout',
          ),
        ],
      ),
        backgroundColor: Colors.white,
        body: const Center(
          child: Text(
            "Home Screen",
            style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
          ),
        ));
  }
}