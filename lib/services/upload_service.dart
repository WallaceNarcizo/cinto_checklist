// lib/services/upload_service.dart
// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class UploadService {
  static const String baseUrl = 'http://192.168.130.242:8080';
  static const String uploadPdfEndpoint = '/api/upload-pdf';
  static const String uploadPdfTombadorEndpoint = '/api/upload-pdf-tombador';
  static const String uploadPdfRampaEndpoint = '/api/upload-pdf-rampa';
  static const String uploadJsonEndpoint = '/api/upload-json';
  static const String uploadJsonTombadorEndpoint = '/api/upload-json-tombador';
  static const String uploadJsonRampaEndpoint = '/api/upload-json-rampa';

  // ============================================================
  // UPLOAD PDF CINTO
  // ============================================================
  static Future<Map<String, dynamic>> uploadPDF({
    required File pdfFile,
    required String nomeInspetor,
    required String equipamento,
    required String status,
    required DateTime data,
    required String observacao,
    required Function(double) onProgress,
  }) async {
    try {
      print('📤 UPLOAD SERVICE CINTO');

      final fileSize = await pdfFile.length();
      print('   📊 Tamanho do arquivo: $fileSize bytes');

      if (fileSize == 0) {
        print('❌ Arquivo PDF está vazio!');
        return {'success': false, 'message': 'Arquivo PDF vazio'};
      }

      String nomeLimpo = nomeInspetor
          .trim()
          .toLowerCase()
          .replaceAll(RegExp(r'[áàãâ]'), 'a')
          .replaceAll(RegExp(r'[éê]'), 'e')
          .replaceAll('í', 'i')
          .replaceAll('ó', 'o')
          .replaceAll('ô', 'o')
          .replaceAll('õ', 'o')
          .replaceAll('ú', 'u')
          .replaceAll('ü', 'u')
          .replaceAll('ç', 'c')
          .replaceAll(' ', '_')
          .replaceAll(RegExp(r'[^a-z0-9_]'), '');

      String dia = data.day.toString().padLeft(2, '0');
      String mes = data.month.toString().padLeft(2, '0');
      String ano = data.year.toString();
      String hora = data.hour.toString().padLeft(2, '0');
      String minuto = data.minute.toString().padLeft(2, '0');

      String statusNome =
          status.toLowerCase() == 'aprovado' ? 'aprovado' : 'rejeitado';
      String nomeArquivo =
          'cinto_${statusNome}_${nomeLimpo}_${dia}_${mes}_${ano}_${hora}h$minuto.pdf';

      print('   📄 Nome do arquivo: $nomeArquivo');

      final bytes = await pdfFile.readAsBytes();
      print('   📊 Bytes lidos: ${bytes.length}');

      var request = http.MultipartRequest(
          'POST', Uri.parse('$baseUrl$uploadPdfEndpoint'));

      request.fields['nomeInspetor'] = nomeInspetor;
      request.fields['equipamento'] = equipamento;
      request.fields['status'] = status;
      request.fields['data'] = data.toIso8601String();
      request.fields['observacao'] = observacao;
      request.fields['nomeArquivo'] = nomeArquivo;

      request.files.add(http.MultipartFile.fromBytes(
        'pdf',
        bytes,
        filename: nomeArquivo,
      ));

      print('   📤 Enviando request...');
      var response = await request.send();
      var responseData = await http.Response.fromStream(response);

      print('   📤 Resposta: ${response.statusCode} - ${responseData.body}');

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'PDF enviado com sucesso!'};
      } else {
        return {'success': false, 'message': responseData.body};
      }
    } catch (e, stacktrace) {
      print('   ❌ Erro: $e');
      print('   📚 Stacktrace: $stacktrace');
      return {'success': false, 'message': 'Erro: $e'};
    }
  }

  // ============================================================
  // UPLOAD PDF TOMBADOR
  // ============================================================
  static Future<Map<String, dynamic>> uploadPDFTombador({
    required File pdfFile,
    required String nomeInspetor,
    required String equipamento,
    required String status,
    required DateTime data,
    required String observacao,
    required Function(double) onProgress,
  }) async {
    try {
      print('📤 UPLOAD SERVICE TOMBADOR');

      final fileSize = await pdfFile.length();
      print('   📊 Tamanho do arquivo: $fileSize bytes');

      if (fileSize == 0) {
        print('❌ Arquivo PDF está vazio!');
        return {'success': false, 'message': 'Arquivo PDF vazio'};
      }

      String nomeLimpo = nomeInspetor
          .trim()
          .toLowerCase()
          .replaceAll(RegExp(r'[áàãâ]'), 'a')
          .replaceAll(RegExp(r'[éê]'), 'e')
          .replaceAll('í', 'i')
          .replaceAll('ó', 'o')
          .replaceAll('ô', 'o')
          .replaceAll('õ', 'o')
          .replaceAll('ú', 'u')
          .replaceAll('ü', 'u')
          .replaceAll('ç', 'c')
          .replaceAll(' ', '_')
          .replaceAll(RegExp(r'[^a-z0-9_]'), '');

      String dia = data.day.toString().padLeft(2, '0');
      String mes = data.month.toString().padLeft(2, '0');
      String ano = data.year.toString();
      String hora = data.hour.toString().padLeft(2, '0');
      String minuto = data.minute.toString().padLeft(2, '0');

      String statusNome =
          status.toLowerCase() == 'aprovado' ? 'aprovado' : 'rejeitado';
      String nomeArquivo =
          'tombador_${statusNome}_${nomeLimpo}_${dia}_${mes}_${ano}_${hora}h$minuto.pdf';

      print('   📄 Nome do arquivo: $nomeArquivo');

      final bytes = await pdfFile.readAsBytes();
      print('   📊 Bytes lidos: ${bytes.length}');

      var request = http.MultipartRequest(
          'POST', Uri.parse('$baseUrl$uploadPdfTombadorEndpoint'));

      request.fields['nomeInspetor'] = nomeInspetor;
      request.fields['equipamento'] = equipamento;
      request.fields['status'] = status;
      request.fields['data'] = data.toIso8601String();
      request.fields['observacao'] = observacao;
      request.fields['nomeArquivo'] = nomeArquivo;

      request.files.add(http.MultipartFile.fromBytes(
        'pdf',
        bytes,
        filename: nomeArquivo,
      ));

      print('   📤 Enviando request...');
      var response = await request.send();
      var responseData = await http.Response.fromStream(response);

      print('   📤 Resposta: ${response.statusCode} - ${responseData.body}');

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'PDF do Tombador enviado com sucesso!'
        };
      } else {
        return {'success': false, 'message': responseData.body};
      }
    } catch (e, stacktrace) {
      print('   ❌ Erro Tombador: $e');
      print('   📚 Stacktrace: $stacktrace');
      return {'success': false, 'message': 'Erro: $e'};
    }
  }

  // ============================================================
  // UPLOAD PDF RAMPA
  // ============================================================
  static Future<Map<String, dynamic>> uploadPDFRampa({
    required File pdfFile,
    required String nomeInspetor,
    required String equipamento,
    required String status,
    required DateTime data,
    required String observacao,
    required Function(double) onProgress,
  }) async {
    try {
      print('📤 UPLOAD SERVICE RAMPA');

      final fileSize = await pdfFile.length();
      print('   📊 Tamanho do arquivo: $fileSize bytes');

      if (fileSize == 0) {
        print('❌ Arquivo PDF está vazio!');
        return {'success': false, 'message': 'Arquivo PDF vazio'};
      }

      String nomeLimpo = nomeInspetor
          .trim()
          .toLowerCase()
          .replaceAll(RegExp(r'[áàãâ]'), 'a')
          .replaceAll(RegExp(r'[éê]'), 'e')
          .replaceAll('í', 'i')
          .replaceAll('ó', 'o')
          .replaceAll('ô', 'o')
          .replaceAll('õ', 'o')
          .replaceAll('ú', 'u')
          .replaceAll('ü', 'u')
          .replaceAll('ç', 'c')
          .replaceAll(' ', '_')
          .replaceAll(RegExp(r'[^a-z0-9_]'), '');

      String dia = data.day.toString().padLeft(2, '0');
      String mes = data.month.toString().padLeft(2, '0');
      String ano = data.year.toString();
      String hora = data.hour.toString().padLeft(2, '0');
      String minuto = data.minute.toString().padLeft(2, '0');

      String statusNome = status.toLowerCase() == 'apto' ? 'apto' : 'nao_apto';
      String nomeArquivo =
          'rampa_${statusNome}_${nomeLimpo}_${dia}_${mes}_${ano}_${hora}h$minuto.pdf';

      print('   📄 Nome do arquivo: $nomeArquivo');

      final bytes = await pdfFile.readAsBytes();
      print('   📊 Bytes lidos: ${bytes.length}');

      var request = http.MultipartRequest(
          'POST', Uri.parse('$baseUrl$uploadPdfRampaEndpoint'));

      request.fields['nomeInspetor'] = nomeInspetor;
      request.fields['equipamento'] = equipamento;
      request.fields['status'] = status;
      request.fields['data'] = data.toIso8601String();
      request.fields['observacao'] = observacao;
      request.fields['nomeArquivo'] = nomeArquivo;

      request.files.add(http.MultipartFile.fromBytes(
        'pdf',
        bytes,
        filename: nomeArquivo,
      ));

      print('   📤 Enviando request...');
      var response = await request.send();
      var responseData = await http.Response.fromStream(response);

      print('   📤 Resposta: ${response.statusCode} - ${responseData.body}');

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'PDF da Rampa enviado com sucesso!'
        };
      } else {
        return {'success': false, 'message': responseData.body};
      }
    } catch (e, stacktrace) {
      print('   ❌ Erro Rampa: $e');
      print('   📚 Stacktrace: $stacktrace');
      return {'success': false, 'message': 'Erro: $e'};
    }
  }

  // ============================================================
  // UPLOAD JSON CINTO
  // ============================================================
  static Future<Map<String, dynamic>> uploadJsonNaoConformidades({
    required Map<String, dynamic> jsonData,
    required String nomeInspetor,
    required String equipamento,
  }) async {
    try {
      print('📤 Enviando JSON CINTO');
      final response = await http
          .post(
            Uri.parse('$baseUrl$uploadJsonEndpoint'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'nomeInspetor': nomeInspetor,
              'equipamento': equipamento,
              'jsonData': jsonData,
            }),
          )
          .timeout(const Duration(seconds: 30));
      print('   📤 Resposta: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200) {
        return {'success': true, 'message': 'JSON enviado com sucesso!'};
      } else {
        return {'success': false, 'message': response.body};
      }
    } catch (e) {
      print('   ❌ Erro JSON: $e');
      return {'success': false, 'message': 'Erro: $e'};
    }
  }

  // ============================================================
  // UPLOAD JSON TOMBADOR
  // ============================================================
  static Future<Map<String, dynamic>> uploadJsonNaoConformidadesTombador({
    required Map<String, dynamic> jsonData,
    required String nomeInspetor,
    required String equipamento,
  }) async {
    try {
      print('📤 Enviando JSON TOMBADOR');
      final response = await http
          .post(
            Uri.parse('$baseUrl$uploadJsonTombadorEndpoint'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'nomeInspetor': nomeInspetor,
              'equipamento': equipamento,
              'jsonData': jsonData,
            }),
          )
          .timeout(const Duration(seconds: 30));
      print('   📤 Resposta: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'JSON do Tombador enviado com sucesso!'
        };
      } else {
        return {'success': false, 'message': response.body};
      }
    } catch (e) {
      print('   ❌ Erro JSON Tombador: $e');
      return {'success': false, 'message': 'Erro: $e'};
    }
  }

  // ============================================================
  // UPLOAD JSON RAMPA
  // ============================================================
  static Future<Map<String, dynamic>> uploadJsonNaoConformidadesRampa({
    required Map<String, dynamic> jsonData,
    required String nomeInspetor,
    required String equipamento,
  }) async {
    try {
      print('📤 Enviando JSON RAMPA');
      final response = await http
          .post(
            Uri.parse('$baseUrl$uploadJsonRampaEndpoint'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'nomeInspetor': nomeInspetor,
              'equipamento': equipamento,
              'jsonData': jsonData,
            }),
          )
          .timeout(const Duration(seconds: 30));
      print('   📤 Resposta: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'JSON da Rampa enviado com sucesso!'
        };
      } else {
        return {'success': false, 'message': response.body};
      }
    } catch (e) {
      print('   ❌ Erro JSON Rampa: $e');
      return {'success': false, 'message': 'Erro: $e'};
    }
  }
}
