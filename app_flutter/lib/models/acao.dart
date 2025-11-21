class Acao {
  final int? id;
  final String codigo;
  final String nomeEmpresa;
  final double precoAtual;

  Acao({
    this.id,
    required this.codigo,
    required this.nomeEmpresa,
    required this.precoAtual,
  });

  factory Acao.fromJson(Map<String, dynamic> json) {
    final raw = json['preco_atual'];
    double preco;
    if (raw == null) {
      preco = 0.0;
    } else if (raw is num) {
      preco = raw.toDouble();
    } else if (raw is String) {
      preco = double.tryParse(raw.replaceAll(',', '.')) ?? 0.0;
    } else {
      preco = 0.0;
    }

    return Acao(
      id: json['id'] as int?,
      codigo: json['codigo'] ?? '',
      nomeEmpresa: json['nome_empresa'] ?? '',
      precoAtual: preco,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'codigo': codigo,
      'nome_empresa': nomeEmpresa,
      'preco_atual': precoAtual,
    };
  }
}
