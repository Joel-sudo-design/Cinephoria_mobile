import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';

// Indiquez à Mockito de générer un mock pour http.Client
@GenerateMocks([http.Client])
void main() {}
