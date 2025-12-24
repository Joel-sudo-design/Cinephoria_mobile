import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'home_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  static const String _loginUrl = 'https://cinephoria.joeldermont.fr/api/login_check';

  static Future<Map<String, dynamic>> testLogin({
    required String email,
    required String password,
    required http.Client client,
  }) async {
    return _postJson(
      client: client,
      url: _loginUrl,
      payload: {'email': email, 'password': password},
    );
  }

  static Future<Map<String, dynamic>> _postJson({
    required http.Client client,
    required String url,
    required Map<String, dynamic> payload,
  }) async {
    final response = await client
        .post(
      Uri.parse(url),
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(payload),
    )
        .timeout(const Duration(seconds: 12));

    final ct = (response.headers['content-type'] ?? '').toLowerCase();

    if (!ct.contains('application/json')) {
      final body = response.body;
      final preview = body.isEmpty
          ? ''
          : body.substring(0, body.length > 250 ? 250 : body.length);
      throw Exception('Réponse non JSON (HTTP ${response.statusCode}) ${preview.isEmpty ? "" : "\n$preview"}');
    }

    final dynamic decoded = jsonDecode(response.body);
    final Map<String, dynamic> data =
    decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};

    if (response.statusCode == 200) return data;

    final msg = (data['message'] ?? data['error'] ?? 'Erreur HTTP ${response.statusCode}').toString();
    throw Exception(msg);
  }

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _storage = const FlutterSecureStorage();

  bool _isButtonPressed = false;
  String _message = '';
  bool _isError = false;
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _message = '';
      _isError = false;
    });

    try {
      final data = await LoginPage.testLogin(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        client: http.Client(),
      );

      final token = data['token'];
      if (token is! String || token.isEmpty) {
        throw Exception("Pas de token dans la réponse.");
      }

      await _storage.write(key: 'token', value: token);

      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isButtonPressed = false;
        _isError = false;
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isButtonPressed = false;
        _isError = true;
        _message = "Erreur : $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final background = MaterialStateProperty.resolveWith<Color?>(
          (states) => _isButtonPressed ? Colors.white : Colors.transparent,
    );

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6A73AB), Color(0xFF2B2E45)],
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
                Image.asset('assets/images/logo.png', height: 150),
                const SizedBox(height: 50),
                Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          hintText: 'Entrer votre email',
                          border: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF7749F8))),
                          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                          labelStyle: TextStyle(color: Colors.white),
                          hintStyle: TextStyle(color: Colors.white),
                        ),
                        style: const TextStyle(color: Colors.white),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Veuillez entrer un email';
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
                          border: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                          focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF7749F8))),
                          enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                          labelStyle: const TextStyle(color: Colors.white),
                          hintStyle: const TextStyle(color: Colors.white),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.white),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Veuillez entrer un mot de passe';
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.4,
                        child: TextButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                            if (_formKey.currentState?.validate() ?? false) {
                              setState(() => _isButtonPressed = true);
                              _login();
                            }
                          },
                          style: ButtonStyle(
                            backgroundColor: background,
                            side: MaterialStateProperty.all(
                              BorderSide(
                                color: _isButtonPressed ? const Color(0xFF6A73AB) : Colors.white,
                                width: 1,
                              ),
                            ),
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                            padding: MaterialStateProperty.all(const EdgeInsets.symmetric(vertical: 10)),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6A73AB)),
                          )
                              : Text(
                            'CONNEXION',
                            style: TextStyle(
                              color: _isButtonPressed ? const Color(0xFF6A73AB) : Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (_message.isNotEmpty)
                        Text(
                          _message,
                          style: TextStyle(
                            color: _isError ? Colors.red : Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
