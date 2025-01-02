import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Connexion")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const TextField(
              decoration: InputDecoration(labelText: "Nom d'utilisateur"),
            ),
            const TextField(
              decoration: InputDecoration(labelText: "Mot de passe"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Redirection vers la page d'accueil après connexion
                Navigator.pushReplacementNamed(context, '/home');
              },
              child: const Text("Se connecter"),
            ),
          ],
        ),
      ),
    );
  }
}
