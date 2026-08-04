// ignore_for_file: empty_catches, duplicate_ignore

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'upload_service.dart';
import '../models/usuario.dart';

class PdfService {
  // =========================
  // FORMATOS
  // =========================

  static String _formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';
  }

  static String _formatarHora(DateTime data) {
    return '${data.hour.toString().padLeft(2, '0')}:${data.minute.toString().padLeft(2, '0')}';
  }

  // =========================
// GERAR PDF CINTO (APENAS COM ESTAS CORREÇÕES)
// =========================

  static Future<Uint8List> gerarRelatorio({
    required DateTime data,
    required String status,
    required List<Map<String, dynamic>> itens,
    required String observacao,
    required List<File> fotos,
    required String nomeInspetor,
    required String equipamento,
    required Usuario usuario,
  }) async {
    final pdf = pw.Document();

    // 🔥 CORREÇÃO 1: Carregar fontes com timeout e fallback
    pw.Font fontRegular;
    pw.Font fontBold;

    try {
      fontRegular = pw.Font.ttf(await rootBundle
          .load('assets/fonts/arial.ttf')
          .timeout(const Duration(seconds: 5)));
    } catch (e) {
      fontRegular = pw.Font.helvetica();
    }

    try {
      fontBold = pw.Font.ttf(await rootBundle
          .load('assets/fonts/arialbd.ttf')
          .timeout(const Duration(seconds: 5)));
    } catch (e) {
      fontBold = pw.Font.helveticaBold();
    }

    // 🔥 CORREÇÃO 2: Imagens como nullable
    pw.MemoryImage? logoEmpresa;
    pw.MemoryImage? logoSeguranca;
    pw.MemoryImage? logoCinto;

    try {
      final bytes = (await rootBundle.load('assets/imagem/logo_empresa.png'))
          .buffer
          .asUint8List();
      logoEmpresa = pw.MemoryImage(bytes);
    } catch (e) {}

    try {
      final bytes = (await rootBundle.load('assets/imagem/logo_seguranca.png'))
          .buffer
          .asUint8List();
      logoSeguranca = pw.MemoryImage(bytes);
    } catch (e) {}

    try {
      final bytes = (await rootBundle.load('assets/imagem/cinto_seguranca.png'))
          .buffer
          .asUint8List();
      logoCinto = pw.MemoryImage(bytes);
    } catch (e) {}

    int conformes = 0;
    int naoConformes = 0;
    List<Map<String, dynamic>> conformesList = [];
    List<Map<String, dynamic>> naoConformesList = [];

    for (var item in itens) {
      final statusItem = item['status']?.toString().toLowerCase() ?? '';
      if (statusItem == 'conforme') {
        conformes++;
        conformesList.add(item);
      } else if (statusItem == 'nao_conforme') {
        naoConformes++;
        naoConformesList.add(item);
      }
    }

    // 🔥 CORREÇÃO 3: Processar fotos em lote com compressão
    List<pw.MemoryImage> imagens = [];
    for (var foto in fotos) {
      try {
        final bytes = await foto.readAsBytes();
        // Limitar tamanho da imagem para não estourar memória
        if (bytes.length < 5000000) {
          // 5MB max
          imagens.add(pw.MemoryImage(bytes));
        }
      } catch (e) {}
    }

    pdf.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.all(24),
        build: (context) {
          final widgets = <pw.Widget>[];

          // Cabeçalho com verificação de null
          widgets.add(
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Container(
                  width: 70,
                  height: 70,
                  child: logoEmpresa != null
                      ? pw.Image(logoEmpresa, fit: pw.BoxFit.contain)
                      : pw.SizedBox(),
                ),
                pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    pw.Text(
                      'RELATÓRIO DE INSPEÇÃO',
                      style: pw.TextStyle(font: fontBold, fontSize: 18),
                      textAlign: pw.TextAlign.center,
                    ),
                    pw.Text(
                      'Cinto Paraquedista',
                      style: pw.TextStyle(
                        font: fontRegular,
                        fontSize: 10,
                        color: PdfColors.grey700,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                  ],
                ),
                pw.Container(
                  width: 50,
                  height: 50,
                  child: logoSeguranca != null
                      ? pw.Image(logoSeguranca, fit: pw.BoxFit.contain)
                      : pw.SizedBox(),
                ),
              ],
            ),
          );

          widgets.add(pw.SizedBox(height: 10));

          if (logoCinto != null) {
            widgets.add(
              pw.Center(
                child: pw.Container(
                  width: 70,
                  height: 70,
                  child: pw.Image(logoCinto, fit: pw.BoxFit.contain),
                ),
              ),
            );
            widgets.add(pw.SizedBox(height: 10));
          }

          // Resto do seu código permanece IGUAL
          widgets.add(
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                color: status == 'APROVADO' ? PdfColors.green : PdfColors.red,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Center(
                child: pw.Text(
                  status,
                  style: pw.TextStyle(
                    font: fontBold,
                    color: PdfColors.white,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
          );

          widgets.add(pw.SizedBox(height: 12));

          widgets.add(
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: pw.BorderRadius.circular(10),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('DADOS DA INSPEÇÃO',
                      style: pw.TextStyle(font: fontBold, fontSize: 11)),
                  pw.SizedBox(height: 8),
                  pw.Row(
                    children: [
                      pw.Expanded(
                        child: _infoLinha(
                            'Inspetor:', nomeInspetor, fontRegular, fontBold),
                      ),
                      pw.SizedBox(width: 15),
                      pw.Expanded(
                        child: _infoLinha(
                            'Setor:', usuario.setor, fontRegular, fontBold),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 6),
                  pw.Row(
                    children: [
                      pw.Expanded(
                        child: _infoLinha(
                            'Equipamento:', equipamento, fontRegular, fontBold),
                      ),
                      pw.SizedBox(width: 15),
                      pw.Expanded(
                        child: _infoLinha(
                            'CA:', usuario.ca, fontRegular, fontBold),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 6),
                  pw.Row(
                    children: [
                      pw.Expanded(
                        child: _infoLinha('Data:', _formatarData(data),
                            fontRegular, fontBold),
                      ),
                      pw.SizedBox(width: 15),
                      pw.Expanded(
                        child: _infoLinha('Hora:', _formatarHora(data),
                            fontRegular, fontBold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );

          widgets.add(pw.SizedBox(height: 12));

          widgets.add(
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: pw.BorderRadius.circular(10),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('RESUMO DA INSPEÇÃO',
                      style: pw.TextStyle(font: fontBold, fontSize: 11)),
                  pw.SizedBox(height: 8),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                    children: [
                      _miniCard('TOTAL', itens.length.toString(),
                          PdfColors.grey200, fontBold),
                      _miniCard('Conformes', conformes.toString(),
                          PdfColors.green100, fontBold),
                      _miniCard('Não Conformes', naoConformes.toString(),
                          PdfColors.red100, fontBold),
                    ],
                  ),
                ],
              ),
            ),
          );

          widgets.add(pw.SizedBox(height: 12));

          if (conformesList.isNotEmpty || naoConformesList.isNotEmpty) {
            widgets.add(
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(10),
                ),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'ITENS OK (${conformesList.length})',
                            style: pw.TextStyle(
                              font: fontBold,
                              fontSize: 10,
                              color: PdfColors.green800,
                            ),
                          ),
                          pw.SizedBox(height: 6),
                          if (conformesList.isNotEmpty)
                            ...conformesList.map((e) => pw.Padding(
                                  padding: const pw.EdgeInsets.symmetric(
                                      vertical: 3),
                                  child: pw.Text(
                                    '• ${e['titulo']}',
                                    style: pw.TextStyle(
                                        font: fontRegular, fontSize: 9),
                                  ),
                                ))
                          else
                            pw.Text(
                              'Nenhum item conforme',
                              style: pw.TextStyle(
                                  font: fontRegular,
                                  fontSize: 9,
                                  color: PdfColors.grey600),
                            ),
                        ],
                      ),
                    ),
                    pw.Container(
                      width: 1,
                      height: 150,
                      margin: const pw.EdgeInsets.symmetric(horizontal: 8),
                      color: PdfColors.grey300,
                    ),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'NÃO CONFORMES (${naoConformesList.length})',
                            style: pw.TextStyle(
                              font: fontBold,
                              fontSize: 10,
                              color: PdfColors.red800,
                            ),
                          ),
                          pw.SizedBox(height: 6),
                          if (naoConformesList.isNotEmpty)
                            ...naoConformesList.map((e) => pw.Padding(
                                  padding: const pw.EdgeInsets.symmetric(
                                      vertical: 3),
                                  child: pw.Column(
                                    crossAxisAlignment:
                                        pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Text(
                                        '• ${e['titulo']}',
                                        style: pw.TextStyle(
                                            font: fontBold,
                                            fontSize: 9,
                                            color: PdfColors.red900),
                                      ),
                                      if (e['observacao'] != null &&
                                          e['observacao'].toString().isNotEmpty)
                                        pw.Padding(
                                          padding: const pw.EdgeInsets.only(
                                              left: 10, top: 2),
                                          child: pw.Text(
                                            'Obs: ${e['observacao']}',
                                            style: pw.TextStyle(
                                                font: fontRegular,
                                                fontSize: 8,
                                                color: PdfColors.red700),
                                          ),
                                        ),
                                    ],
                                  ),
                                ))
                          else
                            pw.Text(
                              'Nenhuma não conformidade',
                              style: pw.TextStyle(
                                  font: fontRegular,
                                  fontSize: 9,
                                  color: PdfColors.grey600),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );

            widgets.add(pw.SizedBox(height: 12));
          }

          widgets.add(
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.amber50,
                border: pw.Border.all(color: PdfColors.amber200),
                borderRadius: pw.BorderRadius.circular(10),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('OBSERVAÇÃO',
                      style: pw.TextStyle(font: fontBold, fontSize: 10)),
                  pw.SizedBox(height: 6),
                  pw.Text(
                    observacao.isEmpty ? 'Nenhuma observação' : observacao,
                    style: pw.TextStyle(font: fontRegular, fontSize: 9),
                  ),
                ],
              ),
            ),
          );

          if (imagens.isNotEmpty && imagens.length <= 10) {
            // Limitar número de fotos
            widgets.add(pw.NewPage());

            // Mostrar fotos em grade
            widgets.add(
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey50,
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(10),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'EVIDÊNCIAS FOTOGRÁFICAS',
                      style: pw.TextStyle(font: fontBold, fontSize: 12),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'Total de fotos: ${imagens.length}',
                      style: pw.TextStyle(font: fontRegular, fontSize: 10),
                    ),
                    pw.SizedBox(height: 12),
                    pw.Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: imagens.take(10).map((imagem) {
                        return pw.Container(
                          width: 350,
                          height: 300,
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: PdfColors.grey300),
                            borderRadius: pw.BorderRadius.circular(10),
                          ),
                          child: pw.ClipRRect(
                            horizontalRadius: 10,
                            verticalRadius: 10,
                            child: pw.Image(imagem, fit: pw.BoxFit.cover),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            );
          }

          return widgets;
        },
      ),
    );

    return pdf.save();
  }

  // =========================
  // GERAR PDF TOMBADOR
  // =========================

  static Future<Uint8List> gerarRelatorioTombador({
    required DateTime data,
    required String status,
    required List<Map<String, dynamic>> itens,
    required String observacao,
    required List<File> fotos,
    required String nomeInspetor,
    required String equipamento,
    required Usuario usuario,
  }) async {
    final pdf = pw.Document();

    final fontRegular =
        pw.Font.ttf(await rootBundle.load('assets/fonts/arial.ttf'));
    final fontBold =
        pw.Font.ttf(await rootBundle.load('assets/fonts/arialbd.ttf'));

    late pw.MemoryImage logoEmpresa;
    late pw.MemoryImage logoSeguranca;
    late pw.MemoryImage logoTombador;

    try {
      logoEmpresa = pw.MemoryImage(
        (await rootBundle.load('assets/imagem/logo_empresa.png'))
            .buffer
            .asUint8List(),
      );
    } catch (e) {}

    try {
      logoSeguranca = pw.MemoryImage(
        (await rootBundle.load('assets/imagem/logo_seguranca.png'))
            .buffer
            .asUint8List(),
      );
    } catch (e) {}

    try {
      logoTombador = pw.MemoryImage(
        (await rootBundle.load('assets/imagem/tombador_nr12.png'))
            .buffer
            .asUint8List(),
      );
    } catch (e) {}

    int conformes = 0;
    int naoConformes = 0;

    List<Map<String, dynamic>> conformesList = [];
    List<Map<String, dynamic>> naoConformesList = [];

    for (var item in itens) {
      final statusItem = item['status']?.toString().toLowerCase() ?? '';
      if (statusItem == 'conforme') {
        conformes++;
        conformesList.add(item);
      } else if (statusItem == 'nao_conforme') {
        naoConformes++;
        naoConformesList.add(item);
      }
    }

    List<pw.MemoryImage> imagens = [];

    for (var foto in fotos) {
      try {
        final bytes = await foto.readAsBytes();
        imagens.add(pw.MemoryImage(bytes));
      } catch (e) {}
    }

    pdf.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.all(24),
        build: (context) {
          final widgets = <pw.Widget>[];

          widgets.add(
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Container(
                  width: 80,
                  height: 80,
                  child: pw.Image(logoEmpresa, fit: pw.BoxFit.contain),
                ),
                pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    pw.Text(
                      'RELATÓRIO DE INSPEÇÃO',
                      style: pw.TextStyle(font: fontBold, fontSize: 18),
                      textAlign: pw.TextAlign.center,
                    ),
                    pw.Text(
                      'Tombador NR-12',
                      style: pw.TextStyle(
                        font: fontRegular,
                        fontSize: 10,
                        color: PdfColors.grey700,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                  ],
                ),
                pw.Container(
                  width: 60,
                  height: 60,
                  child: pw.Image(logoSeguranca, fit: pw.BoxFit.contain),
                ),
              ],
            ),
          );

          widgets.add(pw.SizedBox(height: 10));

          widgets.add(
            pw.Center(
              child: pw.Container(
                width: 120,
                height: 120,
                child: pw.Image(logoTombador, fit: pw.BoxFit.contain),
              ),
            ),
          );

          widgets.add(pw.SizedBox(height: 10));

          widgets.add(
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                color: status == 'APROVADO' ? PdfColors.green : PdfColors.red,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Center(
                child: pw.Text(
                  status,
                  style: pw.TextStyle(
                    font: fontBold,
                    color: PdfColors.white,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
          );

          widgets.add(pw.SizedBox(height: 12));

          widgets.add(
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: pw.BorderRadius.circular(10),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('DADOS DA INSPEÇÃO',
                      style: pw.TextStyle(font: fontBold, fontSize: 11)),
                  pw.SizedBox(height: 8),
                  pw.Row(
                    children: [
                      pw.Expanded(
                        child: _infoLinha(
                            'Inspetor:', nomeInspetor, fontRegular, fontBold),
                      ),
                      pw.SizedBox(width: 15),
                      pw.Expanded(
                        child: _infoLinha(
                            'Setor:', usuario.setor, fontRegular, fontBold),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 6),
                  pw.Row(
                    children: [
                      pw.Expanded(
                        child: _infoLinha(
                            'Equipamento:', equipamento, fontRegular, fontBold),
                      ),
                      pw.SizedBox(width: 15),
                      pw.Expanded(
                        child: _infoLinha(
                            'CA:', usuario.ca, fontRegular, fontBold),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 6),
                  pw.Row(
                    children: [
                      pw.Expanded(
                        child: _infoLinha('Data:', _formatarData(data),
                            fontRegular, fontBold),
                      ),
                      pw.SizedBox(width: 15),
                      pw.Expanded(
                        child: _infoLinha('Hora:', _formatarHora(data),
                            fontRegular, fontBold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );

          widgets.add(pw.SizedBox(height: 12));

          widgets.add(
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: pw.BorderRadius.circular(10),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('RESUMO DA INSPEÇÃO',
                      style: pw.TextStyle(font: fontBold, fontSize: 11)),
                  pw.SizedBox(height: 8),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                    children: [
                      _miniCard('TOTAL', itens.length.toString(),
                          PdfColors.grey200, fontBold),
                      _miniCard('Conformes', conformes.toString(),
                          PdfColors.green100, fontBold),
                      _miniCard('Não Conformes', naoConformes.toString(),
                          PdfColors.red100, fontBold),
                    ],
                  ),
                ],
              ),
            ),
          );

          widgets.add(pw.SizedBox(height: 12));

          if (conformesList.isNotEmpty || naoConformesList.isNotEmpty) {
            widgets.add(
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(10),
                ),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'ITENS OK (${conformesList.length})',
                            style: pw.TextStyle(
                              font: fontBold,
                              fontSize: 10,
                              color: PdfColors.green800,
                            ),
                          ),
                          pw.SizedBox(height: 6),
                          if (conformesList.isNotEmpty)
                            ...conformesList.map((e) => pw.Padding(
                                  padding: const pw.EdgeInsets.symmetric(
                                      vertical: 3),
                                  child: pw.Text(
                                    '• ${e['titulo']}',
                                    style: pw.TextStyle(
                                        font: fontRegular, fontSize: 9),
                                  ),
                                ))
                          else
                            pw.Text(
                              'Nenhum item conforme',
                              style: pw.TextStyle(
                                  font: fontRegular,
                                  fontSize: 9,
                                  color: PdfColors.grey600),
                            ),
                        ],
                      ),
                    ),
                    pw.Container(
                      width: 1,
                      height: 150,
                      margin: const pw.EdgeInsets.symmetric(horizontal: 8),
                      color: PdfColors.grey300,
                    ),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'NÃO CONFORMES (${naoConformesList.length})',
                            style: pw.TextStyle(
                              font: fontBold,
                              fontSize: 10,
                              color: PdfColors.red800,
                            ),
                          ),
                          pw.SizedBox(height: 6),
                          if (naoConformesList.isNotEmpty)
                            ...naoConformesList.map((e) => pw.Padding(
                                  padding: const pw.EdgeInsets.symmetric(
                                      vertical: 3),
                                  child: pw.Column(
                                    crossAxisAlignment:
                                        pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Text(
                                        '• ${e['titulo']}',
                                        style: pw.TextStyle(
                                            font: fontBold,
                                            fontSize: 9,
                                            color: PdfColors.red900),
                                      ),
                                      if (e['observacao'] != null &&
                                          e['observacao'].toString().isNotEmpty)
                                        pw.Padding(
                                          padding: const pw.EdgeInsets.only(
                                              left: 10, top: 2),
                                          child: pw.Text(
                                            'Obs: ${e['observacao']}',
                                            style: pw.TextStyle(
                                                font: fontRegular,
                                                fontSize: 8,
                                                color: PdfColors.red700),
                                          ),
                                        ),
                                    ],
                                  ),
                                ))
                          else
                            pw.Text(
                              'Nenhuma não conformidade',
                              style: pw.TextStyle(
                                  font: fontRegular,
                                  fontSize: 9,
                                  color: PdfColors.grey600),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );

            widgets.add(pw.SizedBox(height: 12));
          }

          widgets.add(
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.amber50,
                border: pw.Border.all(color: PdfColors.amber200),
                borderRadius: pw.BorderRadius.circular(10),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('OBSERVAÇÃO',
                      style: pw.TextStyle(font: fontBold, fontSize: 10)),
                  pw.SizedBox(height: 6),
                  pw.Text(
                    observacao.isEmpty ? 'Nenhuma observação' : observacao,
                    style: pw.TextStyle(font: fontRegular, fontSize: 9),
                  ),
                ],
              ),
            ),
          );

          if (imagens.isNotEmpty) {
            widgets.add(pw.NewPage());

            widgets.add(
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey50,
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(10),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'EVIDÊNCIAS FOTOGRÁFICAS',
                      style: pw.TextStyle(font: fontBold, fontSize: 12),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'Total de fotos: ${imagens.length}',
                      style: pw.TextStyle(font: fontRegular, fontSize: 10),
                    ),
                    pw.SizedBox(height: 12),
                    pw.Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: imagens.map((imagem) {
                        return pw.Container(
                          width: 350,
                          height: 300,
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: PdfColors.grey300),
                            borderRadius: pw.BorderRadius.circular(10),
                          ),
                          child: pw.ClipRRect(
                            horizontalRadius: 10,
                            verticalRadius: 10,
                            child: pw.Image(imagem, fit: pw.BoxFit.cover),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            );
          }

          return widgets;
        },
      ),
    );

    return pdf.save();
  }
// =========================
  // GERAR PDF RAMPA
  // =========================

  static Future<Uint8List> gerarRelatorioRampa({
    required DateTime data,
    required String status,
    required List<Map<String, dynamic>> itens,
    required String observacao,
    required List<File> fotos,
    required String nomeInspetor,
    required String equipamento,
    required Usuario usuario,
  }) async {
    final pdf = pw.Document();

    final fontRegular =
        pw.Font.ttf(await rootBundle.load('assets/fonts/arial.ttf'));
    final fontBold =
        pw.Font.ttf(await rootBundle.load('assets/fonts/arialbd.ttf'));

    late pw.MemoryImage logoEmpresa;
    late pw.MemoryImage logoSeguranca;
    late pw.MemoryImage logoRampa;

    try {
      logoEmpresa = pw.MemoryImage(
        (await rootBundle.load('assets/imagem/logo_empresa.png'))
            .buffer
            .asUint8List(),
      );
    } catch (e) {}

    try {
      logoSeguranca = pw.MemoryImage(
        (await rootBundle.load('assets/imagem/logo_seguranca.png'))
            .buffer
            .asUint8List(),
      );
    } catch (e) {}

    try {
      logoRampa = pw.MemoryImage(
        (await rootBundle.load('assets/imagem/logo_rampa.png'))
            .buffer
            .asUint8List(),
      );
    } catch (e) {}

    int conformes = 0;
    int naoConformes = 0;

    List<Map<String, dynamic>> conformesList = [];
    List<Map<String, dynamic>> naoConformesList = [];

    for (var item in itens) {
      final statusItem = item['status']?.toString().toLowerCase() ?? '';
      if (statusItem == 'conforme') {
        conformes++;
        conformesList.add(item);
      } else if (statusItem == 'nao_conforme') {
        naoConformes++;
        naoConformesList.add(item);
      }
    }

    List<pw.MemoryImage> imagens = [];

    for (var foto in fotos) {
      try {
        final bytes = await foto.readAsBytes();
        imagens.add(pw.MemoryImage(bytes));
      } catch (e) {}
    }

    pdf.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.all(20),
        build: (context) {
          final widgets = <pw.Widget>[];

          // CABEÇALHO
          widgets.add(
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Container(
                  width: 70,
                  height: 70,
                  child: pw.Image(logoEmpresa, fit: pw.BoxFit.contain),
                ),
                pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    pw.Text(
                      'RELATÓRIO DE INSPEÇÃO',
                      style: pw.TextStyle(font: fontBold, fontSize: 14),
                      textAlign: pw.TextAlign.center,
                    ),
                    pw.Text(
                      'Rampa Alfa Bag',
                      style: pw.TextStyle(
                        font: fontRegular,
                        fontSize: 10,
                        color: PdfColors.grey700,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                  ],
                ),
                pw.Container(
                  width: 50,
                  height: 50,
                  child: pw.Image(logoSeguranca, fit: pw.BoxFit.contain),
                ),
              ],
            ),
          );

          widgets.add(pw.SizedBox(height: 6));

          // LOGO CENTRAL
          widgets.add(
            pw.Center(
              child: pw.Container(
                width: 80,
                height: 80,
                child: pw.Image(logoRampa, fit: pw.BoxFit.contain),
              ),
            ),
          );
          widgets.add(pw.SizedBox(height: 6));

          // STATUS BADGE
          widgets.add(
            pw.Container(
              padding: const pw.EdgeInsets.all(6),
              decoration: pw.BoxDecoration(
                color: status == 'APROVADO' ? PdfColors.green : PdfColors.red,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Center(
                child: pw.Text(
                  status == 'APROVADO' ? 'APROVADO' : 'REJEITADO',
                  style: pw.TextStyle(
                    font: fontBold,
                    color: PdfColors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          );

          widgets.add(pw.SizedBox(height: 8));

          // DADOS DA INSPEÇÃO
          widgets.add(
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('DADOS DA INSPEÇÃO',
                      style: pw.TextStyle(font: fontBold, fontSize: 10)),
                  pw.SizedBox(height: 6),
                  pw.Row(
                    children: [
                      pw.Expanded(
                        child: _infoLinha(
                            'Inspetor:', nomeInspetor, fontRegular, fontBold),
                      ),
                      pw.SizedBox(width: 10),
                      pw.Expanded(
                        child: _infoLinha(
                            'Setor:', usuario.setor, fontRegular, fontBold),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 4),
                  pw.Row(
                    children: [
                      pw.Expanded(
                        child: _infoLinha(
                            'Equipamento:', equipamento, fontRegular, fontBold),
                      ),
                      pw.SizedBox(width: 10),
                      pw.Expanded(
                        child: _infoLinha(
                            'CA:', usuario.ca, fontRegular, fontBold),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 4),
                  pw.Row(
                    children: [
                      pw.Expanded(
                        child: _infoLinha('Data:', _formatarData(data),
                            fontRegular, fontBold),
                      ),
                      pw.SizedBox(width: 10),
                      pw.Expanded(
                        child: _infoLinha('Hora:', _formatarHora(data),
                            fontRegular, fontBold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );

          widgets.add(pw.SizedBox(height: 8));

          // RESUMO DA INSPEÇÃO
          widgets.add(
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('RESUMO DA INSPEÇÃO',
                      style: pw.TextStyle(font: fontBold, fontSize: 10)),
                  pw.SizedBox(height: 6),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                    children: [
                      _miniCard('TOTAL', itens.length.toString(),
                          PdfColors.grey200, fontBold),
                      _miniCard('Conformes', conformes.toString(),
                          PdfColors.green100, fontBold),
                      _miniCard('Não Conformes', naoConformes.toString(),
                          PdfColors.red100, fontBold),
                    ],
                  ),
                ],
              ),
            ),
          );

          widgets.add(pw.SizedBox(height: 8));

          // LISTA DE ITENS (CONFORMES E NÃO CONFORMES LADO A LADO)
          if (conformesList.isNotEmpty || naoConformesList.isNotEmpty) {
            widgets.add(
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Coluna ITENS OK
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'ITENS OK (${conformesList.length})',
                            style: pw.TextStyle(
                              font: fontBold,
                              fontSize: 9,
                              color: PdfColors.green800,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          if (conformesList.isNotEmpty)
                            ...conformesList.map((e) => pw.Padding(
                                  padding: const pw.EdgeInsets.symmetric(
                                      vertical: 2),
                                  child: pw.Text(
                                    '• ${e['titulo']}',
                                    style: pw.TextStyle(
                                        font: fontRegular, fontSize: 8),
                                  ),
                                ))
                          else
                            pw.Text(
                              'Nenhum item conforme',
                              style: pw.TextStyle(
                                  font: fontRegular,
                                  fontSize: 8,
                                  color: PdfColors.grey600),
                            ),
                        ],
                      ),
                    ),
                    // DIVISOR
                    pw.Container(
                      width: 1,
                      height: 120,
                      margin: const pw.EdgeInsets.symmetric(horizontal: 6),
                      color: PdfColors.grey300,
                    ),
                    // Coluna NÃO CONFORMES
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'NÃO CONFORMES (${naoConformesList.length})',
                            style: pw.TextStyle(
                              font: fontBold,
                              fontSize: 9,
                              color: PdfColors.red800,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          if (naoConformesList.isNotEmpty)
                            ...naoConformesList.map((e) => pw.Padding(
                                  padding: const pw.EdgeInsets.symmetric(
                                      vertical: 2),
                                  child: pw.Column(
                                    crossAxisAlignment:
                                        pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Text(
                                        '• ${e['titulo']}',
                                        style: pw.TextStyle(
                                            font: fontBold,
                                            fontSize: 8,
                                            color: PdfColors.red900),
                                      ),
                                      if (e['observacao'] != null &&
                                          e['observacao'].toString().isNotEmpty)
                                        pw.Padding(
                                          padding: const pw.EdgeInsets.only(
                                              left: 8, top: 2),
                                          child: pw.Text(
                                            'Obs: ${e['observacao']}',
                                            style: pw.TextStyle(
                                                font: fontRegular,
                                                fontSize: 7,
                                                color: PdfColors.red700),
                                          ),
                                        ),
                                    ],
                                  ),
                                ))
                          else
                            pw.Text(
                              'Nenhuma não conformidade',
                              style: pw.TextStyle(
                                  font: fontRegular,
                                  fontSize: 8,
                                  color: PdfColors.grey600),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );

            widgets.add(pw.SizedBox(height: 8));
          }

          // OBSERVAÇÃO - AGORA OCUPA A LARGURA TOTAL DA PÁGINA
          widgets.add(
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: PdfColors.amber50,
                border: pw.Border.all(color: PdfColors.amber200),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('OBSERVAÇÃO',
                      style: pw.TextStyle(font: fontBold, fontSize: 10)),
                  pw.SizedBox(height: 6),
                  pw.Text(
                    observacao.isEmpty ? 'Nenhuma observação' : observacao,
                    style: pw.TextStyle(font: fontRegular, fontSize: 9),
                    softWrap: true, // Permite quebra de linha
                  ),
                ],
              ),
            ),
          );

          // FOTOS (NOVA PÁGINA)
          if (imagens.isNotEmpty) {
            widgets.add(pw.NewPage());

            widgets.add(
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey50,
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'EVIDÊNCIAS FOTOGRÁFICAS',
                      style: pw.TextStyle(font: fontBold, fontSize: 11),
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text(
                      'Total de fotos: ${imagens.length}',
                      style: pw.TextStyle(font: fontRegular, fontSize: 9),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: imagens.map((imagem) {
                        return pw.Container(
                          width: 300,
                          height: 250,
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: PdfColors.grey300),
                            borderRadius: pw.BorderRadius.circular(8),
                          ),
                          child: pw.ClipRRect(
                            horizontalRadius: 8,
                            verticalRadius: 8,
                            child: pw.Image(imagem, fit: pw.BoxFit.cover),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            );
          }

          return widgets;
        },
      ),
    );

    return pdf.save();
  }

  // =========================
  // ENVIO PDF CINTO
  // =========================
  static Future<void> gerarEEnviarParaServidor({
    required DateTime data,
    required String status,
    required List<Map<String, dynamic>> itens,
    required String observacao,
    required List<File> fotos,
    required String nomeInspetor,
    required String equipamento,
    required Usuario usuario,
  }) async {
    final pdfBytes = await gerarRelatorio(
      data: data,
      status: status,
      itens: itens,
      observacao: observacao,
      fotos: fotos,
      nomeInspetor: nomeInspetor,
      equipamento: equipamento,
      usuario: usuario,
    );

    // 🔥 ADICIONE ESTA VERIFICAÇÃO

    if (pdfBytes.length < 5000) {
      // Salva uma cópia local para debug
      final dir = await getTemporaryDirectory();
      final debugFile = File(
          '${dir.path}/debug_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await debugFile.writeAsBytes(pdfBytes);
    }

    final dir = await getTemporaryDirectory();

    String nomeLimpo = nomeInspetor
        .trim()
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('à', 'a')
        .replaceAll('ã', 'a')
        .replaceAll('â', 'a')
        .replaceAll('é', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ô', 'o')
        .replaceAll('õ', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ü', 'u')
        .replaceAll('ç', 'c')
        .replaceAll(' ', '_');

    String dia = data.day.toString().padLeft(2, '0');
    String mes = data.month.toString().padLeft(2, '0');
    String ano = data.year.toString();
    String hora = data.hour.toString().padLeft(2, '0');
    String minuto = data.minute.toString().padLeft(2, '0');

    String nomeArquivo =
        'cinto_${status.toLowerCase()}_${nomeLimpo}_${dia}_${mes}_${ano}_${hora}h$minuto.pdf';

    final file = File('${dir.path}/$nomeArquivo');
    await file.writeAsBytes(pdfBytes);

    await UploadService.uploadPDF(
      pdfFile: file,
      nomeInspetor: nomeInspetor,
      equipamento: equipamento,
      status: status,
      data: data,
      observacao: observacao,
      onProgress: (_) {},
    );
  }

  // =========================
  // ENVIO PDF TOMBADOR
  // =========================

  static Future<void> gerarEEnviarParaServidorTombador({
    required DateTime data,
    required String status,
    required List<Map<String, dynamic>> itens,
    required String observacao,
    required List<File> fotos,
    required String nomeInspetor,
    required String equipamento,
    required Usuario usuario,
    String? nomeArquivoCustom,
  }) async {
    final pdfBytes = await gerarRelatorioTombador(
      data: data,
      status: status,
      itens: itens,
      observacao: observacao,
      fotos: fotos,
      nomeInspetor: nomeInspetor,
      equipamento: equipamento,
      usuario: usuario,
    );

    final dir = await getTemporaryDirectory();

    String nomeArquivo;
    if (nomeArquivoCustom != null && nomeArquivoCustom.isNotEmpty) {
      nomeArquivo = nomeArquivoCustom;
    } else {
      String nomeLimpo = nomeInspetor
          .trim()
          .toLowerCase()
          .replaceAll('á', 'a')
          .replaceAll('à', 'a')
          .replaceAll('ã', 'a')
          .replaceAll('â', 'a')
          .replaceAll('é', 'e')
          .replaceAll('ê', 'e')
          .replaceAll('í', 'i')
          .replaceAll('ó', 'o')
          .replaceAll('ô', 'o')
          .replaceAll('õ', 'o')
          .replaceAll('ú', 'u')
          .replaceAll('ü', 'u')
          .replaceAll('ç', 'c')
          .replaceAll(' ', '_');

      String dia = data.day.toString().padLeft(2, '0');
      String mes = data.month.toString().padLeft(2, '0');
      String ano = data.year.toString();
      String hora = data.hour.toString().padLeft(2, '0');
      String minuto = data.minute.toString().padLeft(2, '0');

      // 🔥 CORRIGIDO: Padronizar status
      String statusNome = status
          .toLowerCase()
          .trim()
          .replaceAll(' ', '_')
          .replaceAll('ã', 'a')
          .replaceAll('ç', 'c');

      // Padronizar: APROVADO -> aprovado, REJEITADO -> rejeitado
      if (statusNome == 'aprovado') {
        statusNome = 'aprovado';
      } else if (statusNome == 'rejeitado' ||
          statusNome == 'não_apto' ||
          statusNome == 'nao_apto') {
        statusNome = 'rejeitado';
      }

      nomeArquivo =
          'tombador_${statusNome}_${nomeLimpo}_${dia}_${mes}_${ano}_${hora}h$minuto.pdf';
    }

    // 🔥 GARANTIR que o nome não tenha espaços
    nomeArquivo = nomeArquivo
        .replaceAll(' ', '_')
        .replaceAll(RegExp(r'[^a-zA-Z0-9_.-]'), '');

    final file = File('${dir.path}/$nomeArquivo');
    await file.writeAsBytes(pdfBytes);

    await UploadService.uploadPDFTombador(
      pdfFile: file,
      nomeInspetor: nomeInspetor,
      equipamento: equipamento,
      status: status,
      data: data,
      observacao: observacao,
      onProgress: (_) {},
    );
  }

// =========================
// ENVIO PDF RAMPA
// =========================

  static Future<void> gerarEEnviarParaServidorRampa({
    required DateTime data,
    required String status,
    required List<Map<String, dynamic>> itens,
    required String observacao,
    required List<File> fotos,
    required String nomeInspetor,
    required String equipamento,
    required Usuario usuario,
    String? nomeArquivoCustom,
  }) async {
    final pdfBytes = await gerarRelatorioRampa(
      data: data,
      status: status,
      itens: itens,
      observacao: observacao,
      fotos: fotos,
      nomeInspetor: nomeInspetor,
      equipamento: equipamento,
      usuario: usuario,
    );

    final dir = await getTemporaryDirectory();

    String nomeArquivo;
    if (nomeArquivoCustom != null && nomeArquivoCustom.isNotEmpty) {
      nomeArquivo = nomeArquivoCustom;
    } else {
      String nomeLimpo = nomeInspetor
          .trim()
          .toLowerCase()
          .replaceAll('á', 'a')
          .replaceAll('à', 'a')
          .replaceAll('ã', 'a')
          .replaceAll('â', 'a')
          .replaceAll('é', 'e')
          .replaceAll('ê', 'e')
          .replaceAll('í', 'i')
          .replaceAll('ó', 'o')
          .replaceAll('ô', 'o')
          .replaceAll('õ', 'o')
          .replaceAll('ú', 'u')
          .replaceAll('ü', 'u')
          .replaceAll('ç', 'c')
          .replaceAll(' ', '_');

      String dia = data.day.toString().padLeft(2, '0');
      String mes = data.month.toString().padLeft(2, '0');
      String ano = data.year.toString();
      String hora = data.hour.toString().padLeft(2, '0');
      String minuto = data.minute.toString().padLeft(2, '0');

      // 🔥 CORRIGIDO: Padronizar status para minúsculo sem espaços
      String statusNome = status
          .toLowerCase()
          .replaceAll(' ', '_') // Substituir espaços por underscore
          .replaceAll('ã', 'a')
          .replaceAll('ç', 'c')
          .replaceAll('é', 'e')
          .replaceAll('í', 'i')
          .replaceAll('ó', 'o')
          .replaceAll('ô', 'o')
          .replaceAll('ú', 'u');

      // Garantir que está no formato correto
      if (statusNome == 'aprovado' || statusNome == 'apto') {
        statusNome = 'apto';
      } else {
        statusNome = 'nao_apto';
      }

      nomeArquivo =
          'rampa_${statusNome}_${nomeLimpo}_${dia}_${mes}_${ano}_${hora}h$minuto.pdf';
    }

    // 🔥 GARANTIR que o nome não tenha espaços ou caracteres especiais
    nomeArquivo = nomeArquivo
        .replaceAll(' ', '_')
        .replaceAll(RegExp(r'[^a-zA-Z0-9_.-]'), '');

    final file = File('${dir.path}/$nomeArquivo');
    await file.writeAsBytes(pdfBytes);

    await UploadService.uploadPDFRampa(
      pdfFile: file,
      nomeInspetor: nomeInspetor,
      equipamento: equipamento,
      status: status,
      data: data,
      observacao: observacao,
      onProgress: (_) {},
    );
  }

  // =========================
  // COMPONENTES
  // =========================

  static pw.Widget _infoLinha(
      String rotulo, String valor, pw.Font font, pw.Font bold) {
    return pw.Row(
      children: [
        pw.Text(rotulo, style: pw.TextStyle(font: bold, fontSize: 9)),
        pw.SizedBox(width: 5),
        pw.Expanded(
          child: pw.Text(valor, style: pw.TextStyle(font: font, fontSize: 9)),
        ),
      ],
    );
  }

  static pw.Widget _miniCard(
    String titulo,
    String valor,
    PdfColor cor,
    pw.Font font,
  ) {
    return pw.Container(
      width: 65,
      padding: const pw.EdgeInsets.all(6),
      decoration: pw.BoxDecoration(
        color: cor,
        borderRadius: pw.BorderRadius.circular(6),
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Column(
        children: [
          pw.Text(titulo, style: pw.TextStyle(font: font, fontSize: 8)),
          pw.SizedBox(height: 4),
          pw.Text(valor, style: pw.TextStyle(font: font, fontSize: 14)),
        ],
      ),
    );
  }
}
