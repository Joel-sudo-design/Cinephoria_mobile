import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'login_screen.dart';
import 'package:cinephoria_mobile/services/commande_service.dart';
import 'package:cinephoria_mobile/models/commande.dart';
import 'package:cinephoria_mobile/screens/QrCodeScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CommandeService _commandeService = CommandeService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  late final Future<List<Commande>> _commandesFuture;

  @override
  void initState() {
    super.initState();
    _commandesFuture = _commandeService.fetchCommandes();
  }

  Future<void> _logout() async {
    await _storage.delete(key: 'token');

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
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
          onPressed: _logout,
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
              future: _commandesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  final err = snapshot.error;

                  if (err is UnauthorizedException) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                            (route) => false,
                      );
                    });

                    return const Center(child: Text('Session expirée…'));
                  }

                  return Center(child: Text('Erreur : $err', style: const TextStyle(color: Colors.red)));
                }

                final commandes = snapshot.data ?? const <Commande>[];
                if (commandes.isEmpty) {
                  return const Center(child: Text('Aucune commande trouvée.'));
                }

                return ListView.builder(
                  itemCount: commandes.length,
                  itemBuilder: (context, index) {
                    final commande = commandes[index];
                    final imageUrl = commande.image.trim();

                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QrCodeScreen(commande: commande),
                          ),
                        );
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(8),
                                topRight: Radius.circular(8),
                              ),
                              child: imageUrl.isEmpty
                                  ? SizedBox(
                                height: 180,
                                width: double.infinity,
                                child: Center(
                                  child: Icon(
                                    Icons.image_not_supported,
                                    color: Colors.grey[400],
                                    size: 50,
                                  ),
                                ),
                              )
                                  : Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                height: 180,
                                width: double.infinity,
                                errorBuilder: (context, error, stackTrace) {
                                  return SizedBox(
                                    height: 180,
                                    width: double.infinity,
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
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    commande.film,
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  Text('Cinéma : ${commande.cinema}', style: const TextStyle(fontSize: 16)),
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
                                  Text('Sièges : ${commande.siegesReserves}', style: const TextStyle(fontSize: 16)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
