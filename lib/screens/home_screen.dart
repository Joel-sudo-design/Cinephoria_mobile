import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'login_screen.dart';
import 'package:cinephoria_mobile/services/commande_service.dart';
import 'package:cinephoria_mobile/models/commande.dart';
import 'package:cinephoria_mobile/screens/QrCodeScreen.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key);

  final CommandeService _commandeService = CommandeService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> _logout(BuildContext context) async {
    await _storage.delete(key: 'token');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
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
          onPressed: () => _logout(context),
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
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            height: 2,
            width: double.infinity,
            color: Colors.grey,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: FutureBuilder<List<Commande>>(
              future: _commandeService.fetchCommandes(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Erreur : ${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Aucune commande trouvée.'));
                } else {
                  final commandes = snapshot.data!;

                  return ListView.builder(
                    itemCount: commandes.length,
                    itemBuilder: (context, index) {
                      final commande = commandes[index];

                      // On détecte le clic sur la Card
                      return InkWell(
                        onTap: () {
                          // On ouvre l'écran du QR code
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => QrCodeScreen(commande: commande),
                            ),
                          );
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Image en haut
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                  topRight: Radius.circular(8),
                                ),
                                child: Image.network(
                                  commande.image,
                                  fit: BoxFit.cover,
                                  height: 180,
                                  width: double.infinity,
                                  errorBuilder: (context, error, stackTrace) {
                                    return SizedBox(
                                      height: 180,
                                      child: Center(
                                        child: Icon(
                                          Icons.image_not_supported,
                                          color: Colors.grey[400],
                                          size: 50,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              // Contenu
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      commande.film,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Cinéma : ${commande.cinema}',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Date : ${commande.date} | Salle : ${commande.salle}',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Heure : ${commande.heureDebut} - ${commande.heureFin}',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Sièges : ${commande.siegesReserves}',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
