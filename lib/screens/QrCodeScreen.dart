import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cinephoria_mobile/models/commande.dart';

class QrCodeScreen extends StatelessWidget {
  final Commande commande;
  const QrCodeScreen({Key? key, required this.commande}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final qrCodeFull = commande.qrCode.trim();

    if (qrCodeFull.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(
            'QR Code - ${commande.film}',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF6A73AB),
        ),
        body: const Center(
          child: Text('QR Code indisponible'),
        ),
      );
    }

    final base64String = qrCodeFull.contains(',')
        ? qrCodeFull.split(',')[1]
        : qrCodeFull;

    final decodedBytes = base64Decode(base64String);

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'QR Code - ${commande.film}',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF6A73AB),
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
