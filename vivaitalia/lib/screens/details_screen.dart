import 'package:flutter/material.dart';

class DetailsScreen extends StatelessWidget {
  const DetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Детали')),
      body: const Center(
        child: Text(
          ' второй экран приложения',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
