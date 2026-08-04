import 'package:flutter/material.dart';
import '../models/item_inspecao_rampa.dart';

class ChecklistTileRampa extends StatelessWidget {
  final ItemInspecaoRampa item;
  final VoidCallback onConforme;
  final VoidCallback onNaoConforme;
  final VoidCallback onReset;

  const ChecklistTileRampa({
    super.key,
    required this.item,
    required this.onConforme,
    required this.onNaoConforme,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor = Colors.white;
    if (item.isConforme) bgColor = Colors.green.shade50;
    if (item.isNaoConforme) bgColor = Colors.red.shade50;

    return Card(
      color: bgColor,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${item.ordem} - ${item.titulo}',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      decoration:
                          item.isConforme ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
                if (!item.isPendente)
                  IconButton(
                    icon: const Icon(Icons.refresh, size: 20),
                    onPressed: onReset,
                    tooltip: 'Resetar',
                  ),
              ],
            ),
            if (item.observacao != null && item.observacao!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '⚠️ ${item.observacao}',
                  style: TextStyle(fontSize: 12, color: Colors.red.shade700),
                ),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: item.isNaoConforme ? null : onConforme,
                    icon: item.isConforme
                        ? const Icon(Icons.check_circle, size: 18)
                        : const Icon(Icons.check, size: 18),
                    label: Text(
                      item.isConforme ? 'CONFORME ✓' : 'CONFORME',
                      style: const TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      disabledBackgroundColor: Colors.green.shade300,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: item.isConforme ? null : onNaoConforme,
                    icon: item.isNaoConforme
                        ? const Icon(Icons.cancel, size: 18)
                        : const Icon(Icons.warning, size: 18),
                    label: Text(
                      item.isNaoConforme ? 'NÃO CONFORME ✗' : 'NÃO CONFORME',
                      style: const TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      disabledBackgroundColor: Colors.red.shade300,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
