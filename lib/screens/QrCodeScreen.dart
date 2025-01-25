import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cinephoria_mobile/models/commande.dart';

class QrCodeScreen extends StatelessWidget {
  final Commande commande;
  const QrCodeScreen({Key? key, required this.commande}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // On récupère la chaîne "data:image/png;base64,...."
    final qrCodeFull = commande.qrCode.trim();

    // On récupère la partie base64 (après la virgule, s’il y en a une)
    final base64String = qrCodeFull.contains(',')
        ? qrCodeFull.split(',')[1]
        : qrCodeFull;

    // Décodage
    final decodedBytes = base64Decode(base64String);

    return Scaffold(
      appBar: AppBar(
        // 1. Met la flèche (icône de retour) en blanc
        iconTheme: const IconThemeData(color: Colors.white),
        // 2. Texte "QR Code" + le nom du film en blanc
        title: Text(
          'QR Code - ${commande.film}',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF6A73AB),
        // La couleur par défaut de la flèche de retour dépend de iconTheme
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Image.memory(decodedBytes),
        ),
      ),
    );
  }
}
