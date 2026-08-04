// lib/screens/checklist_screen.dart
import 'package:flutter/material.dart';
import '../models/checklist_item.dart';
import '../models/usuario.dart';
import '../widgets/expandable_category.dart';
import 'resultado_screen.dart';

class ChecklistScreen extends StatefulWidget {
  final Usuario usuario;

  const ChecklistScreen({
    super.key,
    required this.usuario,
  });

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  List<ChecklistItem> itens = [];
  Map<String, List<ChecklistItem>> itensPorCategoria = {};

  @override
  void initState() {
    super.initState();
    _carregarItens();
  }

  void _carregarItens() {
    itens = [
      // Fitas / Cintagem
      ChecklistItem(
          id: '1',
          titulo: 'Fita de Peito e Costas',
          categoria: 'Fitas / Cintagem',
          ordem: 1),
      ChecklistItem(
          id: '2',
          titulo: 'Fita da Cintura',
          categoria: 'Fitas / Cintagem',
          ordem: 2),
      ChecklistItem(
          id: '3',
          titulo: 'Fita das Pernas',
          categoria: 'Fitas / Cintagem',
          ordem: 3),

      // Costuras
      ChecklistItem(
          id: '4',
          titulo: 'Costura das Fitas dos Ombros',
          categoria: 'Costuras',
          ordem: 4),
      ChecklistItem(
          id: '5',
          titulo: 'Costura do Peito e Costas',
          categoria: 'Costuras',
          ordem: 5),
      ChecklistItem(
          id: '6',
          titulo: 'Costura da Cintura',
          categoria: 'Costuras',
          ordem: 6),
      ChecklistItem(
          id: '7',
          titulo: 'Costura das Pernas',
          categoria: 'Costuras',
          ordem: 7),

      // Anéis Tipo D
      ChecklistItem(
          id: '8',
          titulo: 'Anel Dorsal (Costas)',
          categoria: 'Aneis Tipo D',
          ordem: 8),
      ChecklistItem(
          id: '9',
          titulo: 'Anel Frontal (Peito)',
          categoria: 'Aneis Tipo D',
          ordem: 9),
      ChecklistItem(
          id: '10',
          titulo: 'Anel Lateral (Cintura)',
          categoria: 'Aneis Tipo D',
          ordem: 10),

      // Ajustes e Fivelas
      ChecklistItem(
          id: '11',
          titulo: 'Ajustes das Costas',
          categoria: 'Ajustes e Fivelas',
          ordem: 11),
      ChecklistItem(
          id: '12',
          titulo: 'Ajustes Frontais',
          categoria: 'Ajustes e Fivelas',
          ordem: 12),
      ChecklistItem(
          id: '13',
          titulo: 'Fivela do Peito',
          categoria: 'Ajustes e Fivelas',
          ordem: 13),
      ChecklistItem(
          id: '14',
          titulo: 'Fivelas das Pernas',
          categoria: 'Ajustes e Fivelas',
          ordem: 14),

      // Marcações / Etiquetas
      ChecklistItem(
          id: '15',
          titulo: 'Conforme ABNT / Inmetro',
          categoria: 'Marcacoes / Etiquetas',
          ordem: 15),
      ChecklistItem(
          id: '16',
          titulo: 'Numero de Serie Visivel',
          categoria: 'Marcacoes / Etiquetas',
          ordem: 16),

      // Condições Gerais
      ChecklistItem(
          id: '17',
          titulo: 'Sem Cortes ou Furos',
          categoria: 'Condicoes Gerais',
          ordem: 17),
      ChecklistItem(
          id: '18',
          titulo: 'Sem Desgaste Excessivo',
          categoria: 'Condicoes Gerais',
          ordem: 18),
      ChecklistItem(
          id: '19',
          titulo: 'Sem Contaminacao',
          categoria: 'Condicoes Gerais',
          ordem: 19),
    ];

    itens.sort((a, b) => a.ordem.compareTo(b.ordem));

    itensPorCategoria = {};
    for (var item in itens) {
      if (!itensPorCategoria.containsKey(item.categoria)) {
        itensPorCategoria[item.categoria] = [];
      }
      itensPorCategoria[item.categoria]!.add(item);
    }
  }

  void _marcarConforme(ChecklistItem item) {
    setState(() => item.marcarConforme());
  }

  void _marcarNaoConforme(ChecklistItem item) {
    TextEditingController obsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Registrar Nao Conformidade'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Item: ${item.titulo}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Text('Descreva o problema:'),
              const SizedBox(height: 8),
              TextField(
                controller: obsController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Ex: Fita desgastada...',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
          ),
        ),
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

  void _resetarItem(ChecklistItem item) {
    setState(() => item.resetar());
  }

  void _finalizarInspecao() {
    int pendentes = itens.where((i) => i.isPendente).length;

    if (pendentes > 0) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Inspecao Incompleta'),
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
        builder: (context) => ResultadoScreen(
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

    String caDisplay = widget.usuario.ca;
    String equipamentoDisplay = '';
    if (widget.usuario.ca.contains('/')) {
      final partes = widget.usuario.ca.split('/');
      caDisplay = partes[0];
      equipamentoDisplay = partes.length > 1 ? partes[1] : '';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checklist Cinto Paraquedista'),
        backgroundColor: Colors.blue,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    const Icon(Icons.person, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      widget.usuario.nome.split(' ').first,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.qr_code, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      'Eq: $equipamentoDisplay',
                      style: const TextStyle(fontSize: 10),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.badge, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      'CA: $caDisplay',
                      style: const TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.blue.shade800,
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
          return ExpandableCategory(
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
                : Colors.blue,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('FINALIZAR INSPECAO',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
at