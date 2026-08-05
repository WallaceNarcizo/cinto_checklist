import 'package:flutter/material.dart';
import '../models/item_inspecao.dart';
import 'checklist_tile_tombador.dart';

class ExpandableCategoryTombador extends StatefulWidget {
  final String categoria;
  final List<ItemInspecao> itens;
  final Function(ItemInspecao) onConforme;
  final Function(ItemInspecao) onNaoConforme;
  final Function(ItemInspecao) onReset;

  const ExpandableCategoryTombador({
    super.key,
    required this.categoria,
    required this.itens,
    required this.onConforme,
    required this.onNaoConforme,
    required this.onReset,
  });

  @override
  ExpandableCategoryTombadorState createState() =>
      ExpandableCategoryTombadorState();
}

class ExpandableCategoryTombadorState
    extends State<ExpandableCategoryTombador> {
  bool _isExpanded = true;

  int get _concluidosCount =>
      widget.itens.where((item) => !item.isPendente).length;
  int get _naoConformesCount =>
      widget.itens.where((item) => item.isNaoConforme).length;

  Color _getCategoriaColor() {
    if (widget.categoria.contains('Treinamento')) return Colors.blue;
    if (widget.categoria.contains('Mecânicos')) return Colors.teal;
    if (widget.categoria.contains('Hidráulico')) return Colors.cyan;
    if (widget.categoria.contains('Estrutura')) return Colors.orange;
    if (widget.categoria.contains('Operação')) return Colors.purple;
    return Colors.grey;
  }

  IconData _getIconForCategoria() {
    if (widget.categoria.contains('Treinamento')) return Icons.security;
    if (widget.categoria.contains('Mecânicos')) return Icons.settings;
    if (widget.categoria.contains('Hidráulico')) return Icons.water;
    if (widget.categoria.contains('Estrutura')) return Icons.build;
    if (widget.categoria.contains('Operação')) return Icons.person;
    return Icons.checklist;
  }

  @override
  Widget build(BuildContext context) {
    final corCategoria = _getCategoriaColor();
    final totalItens = widget.itens.length;
    final concluidos = _concluidosCount;
    final naoConformes = _naoConformesCount;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: corCategoria.withOpacity(0.1), // ✅ Corrigido
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      // ignore: deprecated_member_use
                      color: corCategoria.withOpacity(0.2), // ✅ Corrigido
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(_getIconForCategoria(),
                        color: corCategoria, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.categoria,
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: corCategoria)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green
                                    .withValues(alpha: 0.1), // ✅ Corrigido
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text('Concluídos: $concluidos/$totalItens',
                                  style: const TextStyle(
                                      fontSize: 10, color: Colors.green)),
                            ),
                            if (naoConformes > 0) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.red
                                      // ignore: deprecated_member_use
                                      .withOpacity(0.1), // ✅ Corrigido
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text('Não Conformes: $naoConformes',
                                    style: const TextStyle(
                                        fontSize: 10, color: Colors.red)),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    duration: const Duration(milliseconds: 200),
                    turns: _isExpanded ? 0.5 : 0,
                    child:
                        Icon(Icons.expand_more, color: corCategoria, size: 28),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState: _isExpanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Column(
              children: widget.itens.map((item) {
                return ChecklistTileTombador(
                  item: item,
                  onConforme: () => widget.onConforme(item),
                  onNaoConforme: () => widget.onNaoConforme(item),
                  onReset: () => widget.onReset(item),
                );
              }).toList(),
            ),
            secondChild: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Text('${widget.itens.length} itens ocultos',
                    style:
                        TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
