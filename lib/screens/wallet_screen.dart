import 'package:flutter/material.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 119, 194, 255),
          title: const Row(
            children: [
              Icon(Icons.wallet, color: Colors.white),
              SizedBox(width: 8), 
              Text(
                'My Account',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.white,
        body: const Center(
          child: Text(
            "Wallet Screen",
            style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
          ),
        ));
  }
}
