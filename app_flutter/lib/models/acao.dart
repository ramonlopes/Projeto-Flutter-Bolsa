class Acao {
  final int id;
  final String codigo;
  final String nomeEmpresa;
  final double precoAtual;

  Acao({
    required this.id,
    required this.codigo,
    required this.nomeEmpresa,
    required this.precoAtual,
  });

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  factory Acao.fromJson(Map<String, dynamic> json) => Acao(
        id: json['id'] is String ? int.parse(json['id']) : (json['id'] as int),
        codigo: json['codigo'] as String,
        nomeEmpresa: json['nome_empresa'] as String,
        precoAtual: _toDouble(json['preco_atual']),
      );
}
