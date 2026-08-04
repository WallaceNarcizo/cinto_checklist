// ignore_for_file: avoid_print
// ignore_for_file: prefer_const_constructors

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../models/usuario.dart';
import '../services/pdf_service.dart';
import '../services/upload_service.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class RampaResultadoScreen extends StatefulWidget {
  final List<Map<String, dynamic>> itens;
  final Usuario usuario;
  final String numeroEquipamento;

  const RampaResultadoScreen({
    super.key,
    required this.itens,
    required this.usuario,
    required this.numeroEquipamento,
  });

  @override
  State<RampaResultadoScreen> createState() => _RampaResultadoScreenState();
}

class _RampaResultadoScreenState extends State<RampaResultadoScreen> {
  String? _statusSelecionado;
  final TextEditingController _observacaoController = TextEditingController();
  final TextEditingController _nomeInspetorController = TextEditingController();
  final TextEditingController _equipamentoController = TextEditingController();
  final List<File> _fotos = [];
  final ImagePicker _picker = ImagePicker();
  bool _isProcessing = false;

  int get totalItens => widget.itens.length;
  int get conformes =>
      widget.itens.where((item) => item['status'] == 'conforme').length;
  int get naoConformes =>
      widget.itens.where((item) => item['status'] == 'nao_conforme').length;

  List<Map<String, String>> get naoConformidades {
    return widget.itens
        .where((item) => item['status'] == 'nao_conforme')
        .map((item) => {
              'titulo': item['titulo'] as String,
              'observacao': item['observacao'] as String? ?? '',
            })
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _nomeInspetorController.text = widget.usuario.nome;
    _equipamentoController.text = widget.numeroEquipamento;

    if (naoConformes > 0) {
      _statusSelecionado = 'rejeitado';
    } else {
      _statusSelecionado = 'aprovado';
    }
  }

  @override
  void dispose() {
    _observacaoController.dispose();
    _nomeInspetorController.dispose();
    _equipamentoController.dispose();
    super.dispose();
  }

  Future<void> _abrirCamera() async {
    try {
      final XFile? foto = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 70,
      );

      if (foto != null) {
        if (!mounted) return;

        final directory = await getApplicationDocumentsDirectory();
        final nomeArquivo = DateTime.now().millisecondsSinceEpoch.toString();
        final caminhoFinal = path.join(directory.path, '$nomeArquivo.jpg');

        final File arquivoSalvo = await File(foto.path).copy(caminhoFinal);

        setState(() {
          _fotos.add(arquivoSalvo);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Foto adicionada com sucesso!'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 1),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao abrir camera: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _abrirGaleria() async {
    try {
      final XFile? foto = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 70,
      );

      if (foto != null) {
        if (!mounted) return;

        final directory = await getApplicationDocumentsDirectory();
        final nomeArquivo = DateTime.now().millisecondsSinceEpoch.toString();
        final caminhoFinal = path.join(directory.path, '$nomeArquivo.jpg');

        final File arquivoSalvo = await File(foto.path).copy(caminhoFinal);

        setState(() {
          _fotos.add(arquivoSalvo);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Foto adicionada com sucesso!'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 1),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao abrir galeria: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _abrirFotoAmpliada(int index) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black87,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            PhotoViewGallery.builder(
              scrollPhysics: const BouncingScrollPhysics(),
              builder: (BuildContext context, int imageIndex) {
                return PhotoViewGalleryPageOptions(
                  imageProvider: FileImage(_fotos[imageIndex]),
                  initialScale: PhotoViewComputedScale.contained,
                  minScale: PhotoViewComputedScale.contained * 0.8,
                  maxScale: PhotoViewComputedScale.covered * 2,
                );
              },
              itemCount: _fotos.length,
              loadingBuilder: (context, event) => Center(
                child: SizedBox(
                  width: 20.0,
                  height: 20.0,
                  child: CircularProgressIndicator(
                    value: event == null
                        ? null
                        : event.cumulativeBytesLoaded /
                            (event.expectedTotalBytes ?? 1),
                  ),
                ),
              ),
              backgroundDecoration: const BoxDecoration(
                color: Colors.black87,
              ),
              pageController: PageController(initialPage: index),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${index + 1} / ${_fotos.length}',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _removerFoto(int index) {
    setState(() {
      _fotos.removeAt(index);
    });
  }

  Future<void> _finalizarInspecao() async {
    if (_isProcessing) return;

    if (_statusSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione APTO ou NÃO APTO antes de finalizar'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final observacao = _observacaoController.text.trim();
    final nomeInspetor = _nomeInspetorController.text.trim();
    final equipamento = _equipamentoController.text.trim();

    if (nomeInspetor.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, informe o nome do inspetor'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (equipamento.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, informe o número/código do equipamento'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final agora = DateTime.now();
      final dia = agora.day.toString().padLeft(2, '0');
      final mes = agora.month.toString().padLeft(2, '0');
      final ano = agora.year;
      final hora = agora.hour.toString().padLeft(2, '0');
      final minuto = agora.minute.toString().padLeft(2, '0');

      String nomeLimpo = widget.usuario.nome
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

      final statusNome = _statusSelecionado == 'aprovado' ? 'apto' : 'nao_apto';
      final nomeBase =
          'rampa_${statusNome}_${nomeLimpo}_${dia}_${mes}_${ano}_${hora}h$minuto';
      final nomeArquivoPDF = '$nomeBase.pdf';

      // Gerar PDF
      final pdfBytes = await PdfService.gerarRelatorioRampa(
        data: DateTime.now(),
        status: _statusSelecionado == 'aprovado' ? 'APTO' : 'NÃO APTO',
        itens: widget.itens,
        observacao: observacao,
        fotos: _fotos,
        nomeInspetor: nomeInspetor,
        equipamento: equipamento,
        usuario: widget.usuario,
      );

      final dir = await getTemporaryDirectory();
      final localFile = File('${dir.path}/$nomeArquivoPDF');
      await localFile.writeAsBytes(pdfBytes);

      if (naoConformidades.isNotEmpty) {
        final jsonData = {
          'inspetor': {
            'nome': nomeInspetor,
            'ca': widget.usuario.ca,
          },
          'equipamento': equipamento,
          'status': _statusSelecionado == 'aprovado' ? 'APTO' : 'NÃO APTO',
          'naoConformidades': naoConformidades
              .map((nc) => {
                    'titulo': nc['titulo'],
                    'observacao': nc['observacao'],
                  })
              .toList(),
          'observacaoGeral': observacao,
          'dataHora': DateTime.now().toIso8601String(),
          'nomeArquivoOriginal': nomeBase,
        };

        await UploadService.uploadJsonNaoConformidadesRampa(
          jsonData: jsonData,
          nomeInspetor: nomeInspetor,
          equipamento: equipamento,
        );
      }

      await UploadService.uploadPDFRampa(
        pdfFile: localFile,
        nomeInspetor: nomeInspetor,
        equipamento: equipamento,
        status: _statusSelecionado == 'aprovado' ? 'APTO' : 'NÃO APTO',
        data: DateTime.now(),
        observacao: observacao,
        onProgress: (_) {},
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_statusSelecionado == 'aprovado'
                ? 'Inspeção finalizada com sucesso!'
                : 'Inspeção finalizada com não conformidades!'),
            backgroundColor:
                _statusSelecionado == 'aprovado' ? Colors.green : Colors.orange,
          ),
        );

        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
          }
        });
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao finalizar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final temNaoConformidades = naoConformes > 0;

    String caDisplay = widget.usuario.ca;
    if (widget.usuario.ca.contains('/')) {
      caDisplay = widget.usuario.ca.split('/').first;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultado da Inspeção - Rampa Alfa Bag'),
        backgroundColor: Colors.indigo.shade700,
        elevation: 2,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Resumo da Inspeção',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildResumoItem(
                            'Total Itens', totalItens.toString(), Colors.blue),
                        _buildResumoItem(
                            'Conformes', conformes.toString(), Colors.green),
                        _buildResumoItem('Não Conformes',
                            naoConformes.toString(), Colors.red),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (naoConformidades.isNotEmpty) ...[
              const Text(
                'Itens com Não Conformidade:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: naoConformidades.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final item = naoConformidades[index];
                    return ListTile(
                      leading: const Icon(Icons.warning, color: Colors.red),
                      title: Text(
                        item['titulo']!,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('Problema: ${item['observacao']}'),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],
            const Text(
              'Status Final:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatusCard(
                    titulo: 'APTO',
                    descricao: 'Operação liberada',
                    cor: Colors.green,
                    isSelecionado: _statusSelecionado == 'aprovado',
                    isHabilitado: !temNaoConformidades,
                    onTap: () =>
                        setState(() => _statusSelecionado = 'aprovado'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatusCard(
                    titulo: 'NÃO APTO',
                    descricao: 'Necessita ajustes',
                    cor: Colors.red,
                    isSelecionado: _statusSelecionado == 'rejeitado',
                    isHabilitado: true,
                    onTap: () =>
                        setState(() => _statusSelecionado = 'rejeitado'),
                  ),
                ),
              ],
            ),
            if (temNaoConformidades) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.orange.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Há $naoConformes item(ns) com não conformidade.',
                        style: TextStyle(color: Colors.orange.shade800),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            const Text(
              'DADOS DO INSPETOR',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nomeInspetorController,
              decoration: InputDecoration(
                labelText: 'Nome do Inspetor *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _equipamentoController,
              decoration: InputDecoration(
                labelText: 'Número/Código do Equipamento *',
                hintText: 'Ex: RAMPA-001',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.indigo.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.badge, color: Colors.indigo.shade700),
                  const SizedBox(width: 8),
                  Text(
                    'CA: $caDisplay',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Observação (opcional):',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _observacaoController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Digite observações adicionais...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Evidências Fotográficas:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'camera') {
                      _abrirCamera();
                    } else if (value == 'galeria') {
                      _abrirGaleria();
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'camera',
                      child: Row(
                        children: [
                          Icon(Icons.camera_alt),
                          SizedBox(width: 8),
                          Text('Tirar Foto'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'galeria',
                      child: Row(
                        children: [
                          Icon(Icons.photo_library),
                          SizedBox(width: 8),
                          Text('Escolher da Galeria'),
                        ],
                      ),
                    ),
                  ],
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.indigo.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.add_a_photo, color: Colors.indigo.shade700),
                        const SizedBox(width: 4),
                        Text(
                          'Adicionar Foto',
                          style: TextStyle(color: Colors.indigo.shade700),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_fotos.isNotEmpty)
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _fotos.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Stack(
                        children: [
                          GestureDetector(
                            onTap: () => _abrirFotoAmpliada(index),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                _fotos[index],
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => _removerFoto(index),
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.6),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close,
                                    size: 16, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: const Center(
                  child: Column(
                    children: [
                      Icon(Icons.camera_alt, size: 48, color: Colors.grey),
                      SizedBox(height: 8),
                      Text(
                        'Nenhuma foto adicionada',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: _isProcessing ? null : _finalizarInspecao,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: _isProcessing
                  ? Colors.grey
                  : (_statusSelecionado == 'aprovado'
                      ? Colors.green
                      : _statusSelecionado == 'rejeitado'
                          ? Colors.red
                          : Colors.indigo.shade700),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isProcessing
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text('ENVIANDO...'),
                    ],
                  )
                : const Text(
                    'FINALIZAR INSPEÇÃO',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildResumoItem(String label, String valor, Color cor) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 4),
        Text(
          valor,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: cor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard({
    required String titulo,
    required String descricao,
    required Color cor,
    required bool isSelecionado,
    required bool isHabilitado,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: isSelecionado ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side:
            isSelecionado ? BorderSide(color: cor, width: 2) : BorderSide.none,
      ),
      child: InkWell(
        onTap: isHabilitado ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelecionado ? cor.withValues(alpha: 0.1) : Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(
                Icons.check_circle,
                color: isHabilitado ? cor : Colors.grey,
                size: 48,
              ),
              const SizedBox(height: 8),
              Text(
                titulo,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isHabilitado ? cor : Colors.grey,
                ),
              ),
              Text(
                descricao,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
