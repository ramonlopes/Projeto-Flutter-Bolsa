class Corretora {
  final int id;
  final String nome;
  final String? cnpj;
  final double? taxaCorretagem;

  Corretora({required this.id, required this.nome, this.cnpj, this.taxaCorretagem});

  factory Corretora.fromJson(Map<String,dynamic> j) {
    double? d(v)=> v==null?null:(v is num? v.toDouble(): double.tryParse(v.toString()));
    return Corretora(
      id: j['id'] as int,
      nome: j['nome'] as String,
      cnpj: j['cnpj'] as String?,
      taxaCorretagem: d(j['taxa_corretagem'] ?? j['taxaCorretagem']),
    );
  }

  Map<String,dynamic> toJson() => {
    'id': id,
    'nome': nome,
    if (cnpj != null) 'cnpj': cnpj,
    if (taxaCorretagem != null) 'taxa_corretagem': taxaCorretagem,
  };
}