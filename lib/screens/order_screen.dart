import 'package:flutter/material.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});
  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 58, 166, 254),
          title: const Row(
            children: [
              SizedBox(width: 4),
              Text(
                'Order',
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
            "Order Screen",
            style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
          ),
        ));
  }
}
