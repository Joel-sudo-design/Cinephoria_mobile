import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'home_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  bool _isButtonPressed = false;
  String _message = '';
  bool _isError = false;
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    final String url = 'http://192.168.1.13:80/api/login';
    final body = jsonEncode({
      'email': _emailController.text,
      'password': _passwordController.text,
    });

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      setState(() {
        _isLoading = false;
        _isButtonPressed = false;
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.containsKey('token')) {
          final token = data['token'];

          await _storage.write(key: 'token', value: token);

          setState(() {
            _isError = false;
          });

          Future.delayed(const Duration(seconds: 1), () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const HomeScreen(),
              ),
            );
          });
        } else {
          setState(() {
            _isError = true;
            _message = "Erreur : Pas de token dans la réponse.";
          });
        }
      } else {
        final data = jsonDecode(response.body);
        setState(() {
          _isError = true;
          _message = data['error'] ?? 'Erreur inconnue';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isError = true;
        _message = "Erreur de connexion : $e";
      });
      print("Erreur lors de la requête : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF6A73AB),
              Color(0xFF2B2E45),
            ],
            stops: [0.3, 1.0],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const SizedBox(height: 50),
                // Logo
                Image.asset(
                  'assets/images/logo.png',
                  height: 150,
                ),
                const SizedBox(height: 50),

                // Formulaire
                Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      // Champ email
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          hintText: 'Entrer votre email',
                          border: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF7749F8)),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          labelStyle: const TextStyle(color: Colors.white),
                          hintStyle: const TextStyle(color: Colors.white),
                        ),
                        style: const TextStyle(color: Colors.white),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer un email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Mot de passe',
                          hintText: 'Entrer votre mot de passe',
                          border: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF7749F8)),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          labelStyle: const TextStyle(color: Colors.white),
                          hintStyle: const TextStyle(color: Colors.white),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer un mot de passe';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),

                      // Bouton Connexion ou Spinner
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.4,
                        child: TextButton(
                          onPressed: _isLoading
                              ? null // Désactiver le bouton pendant le chargement
                              : () {
                            if (_formKey.currentState?.validate() ?? false) {
                              setState(() {
                                _isButtonPressed = true;
                              });

                              // Appeler la fonction de connexion
                              _login();
                            }
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                                  (states) => _isButtonPressed
                                  ? Colors.white
                                  : Colors.transparent,
                            ),
                            side: MaterialStateProperty.all(
                              BorderSide(
                                  color: _isButtonPressed
                                      ? const Color(0xFF6A73AB)
                                      : Colors.white,
                                  width: 1),
                            ),
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            padding: MaterialStateProperty.all(
                              const EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF6A73AB)),
                          )
                              : Text(
                            'CONNEXION',
                            style: TextStyle(
                              color: _isButtonPressed
                                  ? const Color(0xFF6A73AB)
                                  : Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Affichage du message sous le champ
                      if (_message.isNotEmpty) ...[
                        Text(
                          _message,
                          style: TextStyle(
                            color: _isError ? Colors.red : Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
