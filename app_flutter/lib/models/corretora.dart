class Corretora {
  final int? id;
  final String nome;
  final String? cnpj;
  final double? taxaCorretagem;
  final int? usuarioId;
  final double? saldo;

  Corretora({
    this.id,
    required this.nome,
    this.cnpj,
    this.taxaCorretagem,
    this.usuarioId,
    this.saldo,
  });

  factory Corretora.fromJson(Map<String, dynamic> json) {
    return Corretora(
      id: json['id'] as int?,
      nome: json['nome'] ?? '',
      cnpj: json['cnpj'] as String?,
      taxaCorretagem: _toDouble(json['taxa_corretagem'] ?? json['taxaCorretagem']),
      usuarioId: json['usuario_id'] as int? ?? json['usuarioId'] as int?,
      saldo: _toDouble(json['saldo']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'cnpj': cnpj,
      'taxa_corretagem': taxaCorretagem,
      'usuario_id': usuarioId,
      'saldo': saldo,
    };
  }

  Corretora copyWith({
    int? id,
    String? nome,
    String? cnpj,
    double? taxaCorretagem,
    int? usuarioId,
    double? saldo,
  }) {
    return Corretora(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      cnpj: cnpj ?? this.cnpj,
      taxaCorretagem: taxaCorretagem ?? this.taxaCorretagem,
      usuarioId: usuarioId ?? this.usuarioId,
      saldo: saldo ?? this.saldo,
    );
  }
}

// Conversão segura para double
double? _toDouble(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v.replaceAll(',', '.'));
  return null;
}