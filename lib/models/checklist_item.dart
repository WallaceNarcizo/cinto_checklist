class ChecklistItem {
  final String id;
  final String titulo;
  final String categoria;
  final int ordem;
  String status;
  String? observacao;

  ChecklistItem({
    required this.id,
    required this.titulo,
    required this.categoria,
    required this.ordem,
    this.status = 'pendente',
    this.observacao,
  });

  bool get isConforme => status == 'conforme';
  bool get isNaoConforme => status == 'nao_conforme';
  bool get isPendente => status == 'pendente';

  void marcarConforme() {
    status = 'conforme';
    observacao = null;
  }

  void marcarNaoConforme(String obs) {
    status = 'nao_conforme';
    observacao = obs;
  }

  void resetar() {
    status = 'pendente';
    observacao = null;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'categoria': categoria,
      'ordem': ordem,
      'status': status,
      'observacao': observacao,
    };
  }
}
