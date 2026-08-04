class Usuario {
  final String id;
  final String nome;
  final String ca;
  final String setor;
  final String tipo;
  final bool ativo;

  Usuario({
    required this.id,
    required this.nome,
    required this.ca,
    required this.setor,
    required this.tipo,
    required this.ativo,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'].toString(),
      nome: json['nome'],
      ca: json['ca'] ?? json['matricula'],
      setor: json['setor'],
      tipo: json['tipo'],
      ativo: json['ativo'] ?? true,
    );
  }
}
