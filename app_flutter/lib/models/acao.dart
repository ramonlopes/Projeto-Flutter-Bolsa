class Acao {
  final int id;
  final String codigo;
  final String nomeEmpresa;
  final double? precoAtual;
  final double? precoMedio; // novo campo

  Acao({
    required this.id,
    required this.codigo,
    required this.nomeEmpresa,
    this.precoAtual,
    this.precoMedio, // novo
  });

  factory Acao.fromJson(Map<String, dynamic> json) {
    return Acao(
      id: json['id'] as int,
      codigo: json['codigo'] as String,
      nomeEmpresa: json['nomeEmpresa'] ?? json['nome_empresa'] ?? '',
      precoAtual: _toDouble(json['precoAtual'] ?? json['preco_atual']),
      precoMedio: _toDouble(json['precoMedio'] ?? json['preco_medio']), // novo
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'codigo': codigo,
      'nomeEmpresa': nomeEmpresa,
      'precoAtual': precoAtual,
      'precoMedio': precoMedio, // novo
    };
  }

  Acao copyWith({
    int? id,
    String? codigo,
    String? nomeEmpresa,
    double? precoAtual,
    double? precoMedio, // novo
  }) {
    return Acao(
      id: id ?? this.id,
      codigo: codigo ?? this.codigo,
      nomeEmpresa: nomeEmpresa ?? this.nomeEmpresa,
      precoAtual: precoAtual ?? this.precoAtual,
      precoMedio: precoMedio ?? this.precoMedio, // novo
    );
  }
}

double? _toDouble(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v.replaceAll(',', '.'));
  return null;
}
