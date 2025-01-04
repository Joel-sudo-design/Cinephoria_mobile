import 'package:flutter/material.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Cinéphoria",
          style: TextStyle(
            fontSize: 26,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF6A73AB),
        centerTitle: true,
        leading: IconButton(
          icon: Transform.rotate(
            angle: 3.14159,
            child: const Icon(Icons.logout, color: Colors.white),
          ),
          iconSize: 30.0,
          padding: const EdgeInsets.all(10.0),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
          },
        ),
        toolbarHeight: kToolbarHeight + 20,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              "Commandes",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            // Barre
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              height: 2, // Hauteur de la barre
              width: double.infinity,
              color: Colors.grey,
            ),
            const SizedBox(height: 20),
            // Autres éléments du body peuvent être ajoutés ici
          ],
        ),
      ),
    );
  }
}
