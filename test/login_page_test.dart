import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mockito/mockito.dart';

// Import de la classe générée
import 'http_client_test.mocks.dart';

// Import de LoginPage
import 'package:cinephoria_mobile/screens/login_screen.dart';

void main() {
  late MockClient mockHttpClient;

  setUp(() {
    mockHttpClient = MockClient();
  });

  test('Connexion réussie retourne un token', () async {
    // Simuler une réponse 200 avec un token
    final mockResponse = jsonEncode({'token': 'mocked_token'});
    when(
      mockHttpClient.post(
        Uri.parse('https://cinephoria.joeldermont.fr/api/login'),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      ),
    ).thenAnswer((_) async => http.Response(mockResponse, 200));

    // Appeler la méthode testLogin
    final result = await LoginPage.testLogin(
      email: 'email@example.com',
      password: 'motdepasse',
      client: mockHttpClient,
    );

    expect(result['token'], 'mocked_token');
  });

  test('Connexion échouée retourne une exception', () async {
    // Simuler une réponse 401
    final mockResponse = jsonEncode({'error': 'Invalid credentials'});
    when(
      mockHttpClient.post(
        Uri.parse('https://cinephoria.joeldermont.fr/api/login'),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      ),
    ).thenAnswer((_) async => http.Response(mockResponse, 401));

    // Vérifier qu'une exception est levée
    expect(
          () => LoginPage.testLogin(
        email: 'wrong@example.com',
        password: 'badpassword',
        client: mockHttpClient,
      ),
      throwsException,
    );
  });
}
