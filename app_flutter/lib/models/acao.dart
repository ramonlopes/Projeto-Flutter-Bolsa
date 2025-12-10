class Acao {
  final int id;
  final String codigo;
  final String nomeEmpresa;
  final double? precoAtual;

  Acao({
    required this.id,
    required this.codigo,
    required this.nomeEmpresa,
    this.precoAtual,
  });

  factory Acao.fromJson(Map<String, dynamic> j) {
    double? toDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v.replaceAll(',', '.'));
      return null;
    }

    int toInt(dynamic v) {
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    return Acao(
      id: toInt(j['id']),
      codigo: (j['codigo'] ?? j['symbol'] ?? '').toString(),
      nomeEmpresa: (j['nome_empresa'] ?? j['nomeEmpresa'] ?? '').toString(),
      precoAtual: toDouble(j['preco_atual'] ?? j['precoAtual'] ?? j['preco'] ?? j['price']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'codigo': codigo,
      'nome_empresa': nomeEmpresa,
      if (precoAtual != null) 'preco_atual': precoAtual,
    };
  }

  Acao copyWith({String? codigo, String? nomeEmpresa, double? precoAtual}) {
    return Acao(
      id: id,
      codigo: codigo ?? this.codigo,
      nomeEmpresa: nomeEmpresa ?? this.nomeEmpresa,
      precoAtual: precoAtual ?? this.precoAtual,
    );
  }
}
