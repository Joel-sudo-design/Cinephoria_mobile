import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cinephoria_mobile/models/commande.dart';

class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException([this.message = 'Session expirée, reconnecte-toi.']);
  @override
  String toString() => message;
}

class CommandeService {
  final _storage = const FlutterSecureStorage();
  static const String baseUrl = 'https://cinephoria.joeldermont.fr/api';

  Future<List<Commande>> fetchCommandes() async {
    final String? token = await _storage.read(key: 'token');

    if (token == null) {
      throw Exception('Token introuvable – besoin de se connecter');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/commande'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is List) {
        return data.map((cmd) => Commande.fromJson(cmd)).toList();
      }
      throw Exception('Données reçues non conformes');
    }

    if (response.statusCode == 401 || response.statusCode == 403) {
      await _storage.delete(key: 'token');
      throw UnauthorizedException();
    }

    throw Exception('Erreur lors de la récupération des commandes (HTTP ${response.statusCode})');
  }
}
