// lib/services/usuario_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/usuario.dart';

class UsuarioService {
  static const String baseUrl = 'http://192.168.130.242:8080';
  static const String usuariosEndpoint = '/api/usuarios';

  static Future<List<Usuario>> listarUsuarios() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$usuariosEndpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        // 🔥 ORDENAR POR NOME ALFABETICAMENTE
        final usuarios = data.map((json) => Usuario.fromJson(json)).toList();
        usuarios.sort((a, b) => a.nome.compareTo(b.nome));

        return usuarios;
      } else {
        throw Exception('Erro ao carregar usuários: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
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
