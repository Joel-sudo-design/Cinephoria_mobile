import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  bool _isLoading = true;
  List<dynamic> _commandes = [];

  Future<void> _fetchCommandes() async {
    final String? token = await _storage.read(key: 'token');
    if (token == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
      return;
    }

    final response = await http.get(
      Uri.parse('http://192.168.1.13:80/api/commande'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body);
        setState(() {
          _commandes = data;
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur de format des données')),
        );
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la récupération des commandes')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchCommandes();
  }

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
      body: Column(
        children: [
          const SizedBox(height: 20),
          const Text(
            "Commandes",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          // Barre
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            height: 2,
            width: double.infinity,
            color: Colors.grey,
          ),
          const SizedBox(height: 20),
          _isLoading
              ? Expanded(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
              : Expanded(
            child: ListView.builder(
              itemCount: _commandes.length,
              itemBuilder: (context, index) {
                final commande = _commandes[index];
                return ListTile(
                  title: Text(commande['film']),
                  subtitle: Text(
                    'Date: ${commande['date']} - Salle: ${commande['salle']}',
                  ),
                  leading: Image.network(commande['image'] ?? ''),
                  trailing: Text('Sieges: ${commande['sieges_reserves']}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
