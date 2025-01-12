import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cinephoria_mobile/models/commande.dart';

class CommandeService {
  final _storage = const FlutterSecureStorage();
  static const String baseUrl = 'http://192.168.1.13:80/api';

  Future<List<Commande>> fetchCommandes() async {
    final String? token = await _storage.read(key: 'token');

    if (token == null) {
      throw Exception('Token introuvable – besoin de se connecter');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/commande'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is List) {
        return data.map((cmd) => Commande.fromJson(cmd)).toList();
      } else {
        throw Exception('Données reçues non conformes');
      }
    } else {
      throw Exception('Erreur lors de la récupération des commandes');
    }
  }
}
