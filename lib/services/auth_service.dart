// lib/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/usuario.dart';

class AuthService {
  // 🔥 ALTERAR PARA O IP CORRETO DO SEU SERVIDOR
  static const String baseUrl = 'http://192.168.130.242:8080'; // ← MUDAR AQUI
  static const String loginEndpoint = '/api/login';

  static Future<Map<String, dynamic>> login(String ca, String senha) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl$loginEndpoint'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'ca': ca,
              'senha': senha,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final usuario = Usuario.fromJson(data['usuario']);
          return {
            'success': true,
            'usuario': usuario,
            'message': 'Login realizado com sucesso!',
          };
        } else {
          return {
            'success': false,
            'message': data['message'] ?? 'Erro ao fazer login',
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Erro de conexão: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro de conexão: $e',
      };
    }
  }

  static Future<bool> testConnection() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/ping'),
          )
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
