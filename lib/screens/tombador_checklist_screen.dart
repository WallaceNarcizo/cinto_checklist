// ignore_for_file: prefer_const_constructors, duplicate_ignore

import 'package:flutter/material.dart';
import '../models/item_inspecao.dart';
import '../models/usuario.dart';
import '../widgets/expandable_category_tombador.dart';
import 'tombador_resultado_screen.dart';

class TombadorChecklistScreen extends StatefulWidget {
  final Usuario usuario;

  const TombadorChecklistScreen({
    super.key,
    required this.usuario,
  });

  @override
  State<TombadorChecklistScreen> createState() =>
      _TombadorChecklistScreenState();
}

class _TombadorChecklistScreenState extends State<TombadorChecklistScreen> {
  List<ItemInspecao> itens = [];
  Map<String, List<ItemInspecao>> itensPorCategoria = {};

  @override
  void initState() {
    super.initState();
    _carregarItens();
  }

  void _carregarItens() {
    itens = [
      ItemInspecao(
          id: '1',
          titulo: 'Operador treinado e autorizado',
          categoria: 'Treinamento e Segurança',
          ordem: 1),
      ItemInspecao(
          id: '2',
          titulo: 'Área isolada e sinalizada',
          categoria: 'Treinamento e Segurança',
          ordem: 2),
      ItemInspecao(
          id: '3',
          titulo: 'EPCs instalados e funcionando',
          categoria: 'Treinamento e Segurança',
          ordem: 3),
      ItemInspecao(
          id: '4',
          titulo: 'EPIs em bom estado e uso',
          categoria: 'Treinamento e Segurança',
          ordem: 4),
      ItemInspecao(
          id: '5',
          titulo: 'Cabo de aço está em boas condições',
          categoria: 'Componentes Mecânicos',
          ordem: 5),
      ItemInspecao(
          id: '6',
          titulo: 'Sistema elétrico funcionando',
          categoria: 'Componentes Mecânicos',
          ordem: 6),
      ItemInspecao(
          id: '7',
          titulo: 'Botão de emergência funcionando',
          categoria: 'Componentes Mecânicos',
          ordem: 7),
      ItemInspecao(
          id: '8',
          titulo: 'Travas de segurança está correto',
          categoria: 'Componentes Mecânicos',
          ordem: 8),
      ItemInspecao(
          id: '9',
          titulo: 'Nível de óleo hidráulico adequado',
          categoria: 'Sistema Hidráulico',
          ordem: 9),
      ItemInspecao(
          id: '10',
          titulo: 'Sistema hidráulico sem vazamentos',
          categoria: 'Sistema Hidráulico',
          ordem: 10),
      ItemInspecao(
          id: '11',
          titulo: 'Sem peças soltas ou danificadas',
          categoria: 'Estrutura',
          ordem: 11),
      ItemInspecao(
          id: '12',
          titulo: 'Estrutura íntegra',
          categoria: 'Estrutura',
          ordem: 12),
      ItemInspecao(
          id: '14',
          titulo: 'Comandos com funcionamento livre',
          categoria: 'Estrutura',
          ordem: 13),
      ItemInspecao(
          id: '16',
          titulo: 'Proteções instaladas e íntegras',
          categoria: 'Estrutura',
          ordem: 14),
      ItemInspecao(
          id: '17',
          titulo: 'Motorista está no local de espera',
          categoria: 'Operação',
          ordem: 15),
    ];

    itensPorCategoria = {};
    for (var item in itens) {
      if (!itensPorCategoria.containsKey(item.categoria)) {
        itensPorCategoria[item.categoria] = [];
      }
      itensPorCategoria[item.categoria]!.add(item);
    }
  }

  void _marcarConforme(ItemInspecao item) {
    setState(() => item.marcarConforme());
  }

  // 🔥 MÉTODO CORRIGIDO - COM SINGLECHILDSCROLLVIEW
  void _marcarNaoConforme(ItemInspecao item) {
    TextEditingController obsController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Registrar Não Conformidade'),
        content: SingleChildScrollView(
          // 🔥 ADICIONADO - Permite rolagem
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
                maxLines: 2, // 🔥 Reduzido de 3 para 2
                decoration: const InputDecoration(
                  hintText: 'Ex: Cabo desgastado...',
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

  void _resetarItem(ItemInspecao item) {
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
        builder: (context) => TombadorResultadoScreen(
          itens: itens.map((item) => item.toMap()).toList(),
          usuario: widget.usuario,
          numeroEquipamento: numeroEquipamento,
        ),
      ),
    );
  }

  void _mostrarInfoEmergencia() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
            SizedBox(width: 10),
            Text('Procedimento de Emergência'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🎯 OBJETIVO',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Estabelecer ações rápidas e seguras em situações de risco, falhas operacionais ou emergências, garantindo a integridade dos trabalhadores e do equipamento.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📝 OBSERVAÇÃO IMPORTANTE',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.orange,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'É proibido operar qualquer equipamento que apresente risco à segurança, conforme a NR-12.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Text(
                '⚠️ SITUAÇÕES CONSIDERADAS',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    _buildBulletPoint('Falha mecânica ou elétrica'),
                    _buildBulletPoint('Vazamentos (óleo hidráulico, etc.)'),
                    _buildBulletPoint('Ruídos ou vibrações anormais'),
                    _buildBulletPoint('Travamento do equipamento'),
                    _buildBulletPoint('Presença de pessoas em área de risco'),
                    _buildBulletPoint('Quebra de cabo de aço ou componentes'),
                    _buildBulletPoint('Qualquer condição fora da normalidade'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const Text(
                '🚨 AÇÃO IMEDIATA DO OPERADOR',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.red),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    _buildBulletPoint(
                        'PARAR IMEDIATAMENTE O EQUIPAMENTO - Acionar o botão de emergência e desligar a máquina'),
                    _buildBulletPoint(
                        'ISOLAR A ÁREA - Impedir acesso de pessoas não autorizadas, sinalizar o local (se possível)'),
                    _buildBulletPoint(
                        'NÃO TENTAR CORRIGIR - Não realizar ajustes sem autorização e operar o equipamento sob falha'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '📞 COMUNICAÇÃO IMEDIATA',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    _buildBulletPoint(
                        '👷‍♂️ Técnico de Segurança do Trabalho – Ramal 2'),
                    _buildBulletPoint('🔧 Manutenção – Ramal 2'),
                    _buildBulletPoint('👨‍💼 Coordenador – Ramal 3'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const Text(
                '🔧 PROCEDIMENTO DA MANUTENÇÃO',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    _buildNumberPoint('1', 'Avaliar a condição do equipamento'),
                    _buildNumberPoint('2',
                        'Realizar bloqueio e etiquetagem (LOTO, se aplicável)'),
                    _buildNumberPoint('3', 'Identificar a causa da falha'),
                    _buildNumberPoint('4', 'Executar o reparo necessário'),
                    _buildNumberPoint('5', 'Testar o equipamento sem carga'),
                    _buildNumberPoint(
                        '6', 'Liberar somente após garantir condição segura'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red.shade300),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🔒 BLOQUEIO DO EQUIPAMENTO',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.red),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Equipamento deve ser identificado com: "NÃO OPERAR – EM MANUTENÇÃO"',
                      style: TextStyle(fontSize: 12),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Somente a manutenção pode liberar para uso',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              const Text(
                '⚠️ EM CASO DE ACIDENTE',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    _buildNumberPoint('1',
                        'Prestar socorro imediato (sem se colocar em risco)'),
                    _buildNumberPoint('2',
                        'Acionar: Técnico de Segurança (Ramal 2) e o Coordenador (Ramal 3)'),
                    _buildNumberPoint('3', 'Isolar o local para investigação'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.green.shade300),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📋 LIBERAÇÃO PARA OPERAÇÃO',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.green),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'O equipamento só poderá voltar a operar após:',
                      style: TextStyle(fontSize: 12),
                    ),
                    SizedBox(height: 4),
                    Text('• Correção total da falha'),
                    Text('• Teste operacional realizado'),
                    Text('• Liberação da manutenção'),
                    Text('• Avaliação do Técnico de Segurança (se necessário)'),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('FECHAR'),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 12)),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 12))),
        ],
      ),
    );
  }

  Widget _buildNumberPoint(String number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: Colors.orange.shade700,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 12))),
        ],
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
        title: const Text('Checklist Tombador NR-12'),
        backgroundColor: Colors.orange.shade700,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: _mostrarInfoEmergencia,
            tooltip: 'Procedimento de Emergência',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.orange.shade800,
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
          return ExpandableCategoryTombador(
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
                : Colors.orange.shade700,
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
