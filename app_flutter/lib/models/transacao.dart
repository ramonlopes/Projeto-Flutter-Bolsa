class Transacao {
  final int? id;
  final int usuarioId;
  final int acaoId;
  final String tipo; // 'compra' ou 'venda'
  final int quantidade;
  final double precoUnitario;
  final DateTime? dataTransacao;

  // Campos opcionais se vier join
  final String? usuarioNome;
  final String? acaoCodigo;

  Transacao({
    this.id,
    required this.usuarioId,
    required this.acaoId,
    required this.tipo,
    required this.quantidade,
    required this.precoUnitario,
    this.dataTransacao,
    this.usuarioNome,
    this.acaoCodigo,
  });

  factory Transacao.fromJson(Map<String, dynamic> json) {
    return Transacao(
      id: json['id'] as int?,
      usuarioId: json['usuario_id'] as int,
      acaoId: json['acao_id'] as int,
      tipo: json['tipo'] ?? '',
      quantidade: json['quantidade'] as int,
      precoUnitario: (json['preco_unitario'] is num)
          ? (json['preco_unitario'] as num).toDouble()
          : 0.0,
      dataTransacao: json['data_transacao'] != null
          ? DateTime.tryParse(json['data_transacao'])
          : null,
      usuarioNome: json['Usuario']?['nome'],
      acaoCodigo: json['Acao']?['codigo'],
    );
  }

  Map<String, dynamic> toJsonCreate() {
    return {
      'usuario_id': usuarioId,
      'acao_id': acaoId,
      'tipo': tipo,
      'quantidade': quantidade,
      'preco_unitario': precoUnitario,
    };
  }
}