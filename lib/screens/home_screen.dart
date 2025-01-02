import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Page d'accueil")),
      body: Center(
        child: const Text(
          "Bienvenue dans l'application Cinephoria !",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
