import 'package:flutter/material.dart';
import '../models/item_inspecao_rampa.dart';
import '../models/usuario.dart';
import '../widgets/expandable_category_rampa.dart';
import 'rampa_resultado_screen.dart';

class RampaChecklistScreen extends StatefulWidget {
  final Usuario usuario;

  const RampaChecklistScreen({
    super.key,
    required this.usuario,
  });

  @override
  State<RampaChecklistScreen> createState() => _RampaChecklistScreenState();
}

class _RampaChecklistScreenState extends State<RampaChecklistScreen> {
  List<ItemInspecaoRampa> itens = [];
  Map<String, List<ItemInspecaoRampa>> itensPorCategoria = {};

  @override
  void initState() {
    super.initState();
    _carregarItens();
  }

  void _carregarItens() {
    itens = [
      // CONDIÇÕES DA RAMPA DE ACESSO
      ItemInspecaoRampa(
          id: '1',
          titulo: 'Rampa posicionada corretamente e alinhada ao container',
          categoria: 'CONDIÇÕES DA RAMPA',
          ordem: 1),
      ItemInspecaoRampa(
          id: '2',
          titulo: 'Estrutura da rampa sem trincas, danos ou deformações',
          categoria: 'CONDIÇÕES DA RAMPA',
          ordem: 2),
      ItemInspecaoRampa(
          id: '3',
          titulo:
              'Piso da rampa em boas condições (sem buracos, escorregadio ou irregularidades)',
          categoria: 'CONDIÇÕES DA RAMPA',
          ordem: 3),
      ItemInspecaoRampa(
          id: '4',
          titulo: 'Sistema hidráulico/mecânico funcionando normalmente',
          categoria: 'CONDIÇÕES DA RAMPA',
          ordem: 4),
      ItemInspecaoRampa(
          id: '5',
          titulo: 'Travas de segurança da rampa acionadas',
          categoria: 'CONDIÇÕES DA RAMPA',
          ordem: 5),
      ItemInspecaoRampa(
          id: '6',
          titulo: 'Capacidade da rampa compatível com a operação',
          categoria: 'CONDIÇÕES DA RAMPA',
          ordem: 6),
      ItemInspecaoRampa(
          id: '7',
          titulo: 'Área ao redor da rampa livre de obstáculos',
          categoria: 'CONDIÇÕES DA RAMPA',
          ordem: 7),
      ItemInspecaoRampa(
          id: '8',
          titulo: 'Iluminação adequada para operação',
          categoria: 'CONDIÇÕES DA RAMPA',
          ordem: 8),
      ItemInspecaoRampa(
          id: '9',
          titulo: 'Parte elétrica está funcionando em perfeito estado',
          categoria: 'CONDIÇÕES DA RAMPA',
          ordem: 9),
      ItemInspecaoRampa(
          id: '10',
          titulo: 'Utilização do trava-rodas (calço) corretamente instalado',
          categoria: 'CONDIÇÕES DA RAMPA',
          ordem: 10),

      // SEGURANÇA DA OPERAÇÃO
      ItemInspecaoRampa(
          id: '11',
          titulo:
              'Uso obrigatório de EPIs (capacete, bota, colete, luvas, etc.)',
          categoria: 'SEGURANÇA DA OPERAÇÃO',
          ordem: 11),
      ItemInspecaoRampa(
          id: '12',
          titulo: 'Área sinalizada e isolada para operação',
          categoria: 'SEGURANÇA DA OPERAÇÃO',
          ordem: 12),
      ItemInspecaoRampa(
          id: '13',
          titulo: 'Ausência de pessoas não autorizadas na área',
          categoria: 'SEGURANÇA DA OPERAÇÃO',
          ordem: 13),
      ItemInspecaoRampa(
          id: '14',
          titulo: 'Comunicação clara entre operador e conferente',
          categoria: 'SEGURANÇA DA OPERAÇÃO',
          ordem: 14),
      ItemInspecaoRampa(
          id: '15',
          titulo: 'Equipamentos utilizados em bom estado',
          categoria: 'SEGURANÇA DA OPERAÇÃO',
          ordem: 15),
      ItemInspecaoRampa(
          id: '16',
          titulo: 'Não há risco de queda de materiais',
          categoria: 'SEGURANÇA DA OPERAÇÃO',
          ordem: 16),
      ItemInspecaoRampa(
          id: '17',
          titulo: 'Respeito aos limites de carga',
          categoria: 'SEGURANÇA DA OPERAÇÃO',
          ordem: 17),
      ItemInspecaoRampa(
          id: '18',
          titulo: 'Procedimentos de emergência conhecidos pela equipe',
          categoria: 'SEGURANÇA DA OPERAÇÃO',
          ordem: 18),
      ItemInspecaoRampa(
          id: '19',
          titulo: 'Existe extintores por perto',
          categoria: 'SEGURANÇA DA OPERAÇÃO',
          ordem: 19),
    ];

    itensPorCategoria = {};
    for (var item in itens) {
      if (!itensPorCategoria.containsKey(item.categoria)) {
        itensPorCategoria[item.categoria] = [];
      }
      itensPorCategoria[item.categoria]!.add(item);
    }
  }

  void _marcarConforme(ItemInspecaoRampa item) {
    setState(() => item.marcarConforme());
  }

  void _marcarNaoConforme(ItemInspecaoRampa item) {
    TextEditingController obsController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Registrar Não Conformidade'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item.titulo,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 12),
              const Text('Descreva o problema:'),
              const SizedBox(height: 8),
              TextField(
                controller: obsController,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'Ex: Rampa desalinhada...',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
          ),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (obsController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Descreva o problema'),
                    backgroundColor: Colors.orange,
                    duration: Duration(seconds: 2),
                  ),
                );
                return;
              }
              setState(() => item.marcarNaoConforme(obsController.text.trim()));
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _resetarItem(ItemInspecaoRampa item) {
    setState(() => item.resetar());
  }

  void _finalizarInspecao() {
    int pendentes = itens.where((i) => i.isPendente).length;

    if (pendentes > 0) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Inspeção Incompleta'),
          content: Text('Ainda existem $pendentes itens pendentes.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'))
          ],
        ),
      );
      return;
    }

    String numeroEquipamento = '';
    if (widget.usuario.ca.contains('/')) {
      numeroEquipamento = widget.usuario.ca.split('/').last;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RampaResultadoScreen(
          itens: itens.map((item) => item.toMap()).toList(),
          usuario: widget.usuario,
          numeroEquipamento: numeroEquipamento,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int concluidos = itens.where((i) => !i.isPendente).length;
    int naoConformes = itens.where((i) => i.isNaoConforme).length;
    int total = itens.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checklist Rampa Alfa Bag'),
        backgroundColor: Colors.indigo.shade700,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.indigo.shade800,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.check_circle,
                        color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text('$concluidos/$total',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
                if (naoConformes > 0)
                  Row(
                    children: [
                      const Icon(Icons.warning, color: Colors.orange, size: 20),
                      const SizedBox(width: 8),
                      Text('$naoConformes',
                          style: const TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: itensPorCategoria.entries.map((entry) {
          return ExpandableCategoryRampa(
            categoria: entry.key,
            itens: entry.value,
            onConforme: _marcarConforme,
            onNaoConforme: _marcarNaoConforme,
            onReset: _resetarItem,
          );
        }).toList(),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: _finalizarInspecao,
          style: ElevatedButton.styleFrom(
            backgroundColor: concluidos == total
                ? (naoConformes > 0 ? Colors.orange : Colors.green)
                : Colors.indigo.shade700,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('FINALIZAR INSPEÇÃO',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
