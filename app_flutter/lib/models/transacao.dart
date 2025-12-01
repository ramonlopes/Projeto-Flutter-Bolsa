class Transacao {
  final int? id;
  final int usuarioId;
  final int acaoId;
  final String tipo;
  final int quantidade;
  final double precoUnitario;

  final String? tipoOperacao;      // 'PUT' | 'CALL'
  final String? nomeOpcao;
  final double? valorMercado;
  final double? valorStrike;

  // Novos campos
  final DateTime? dataExercicio;
  final double? porcentagemPremio;
  final double? valorPremioLiquido;
  final double? percentualRetorno;
  final double? percentualRetornoLiquido;
  final double? situacaoMomento;
  final double? valorCobertural;
  final bool? exercidoOperacao;
  final String? corretoraOperada;
  final double? valorIrrrf;

  final DateTime? dataTransacao;

  // joins
  final String? usuarioNome;
  final String? acaoCodigo;

  Transacao({
    this.id,
    required this.usuarioId,
    required this.acaoId,
    required this.tipo,
    required this.quantidade,
    required this.precoUnitario,
    this.tipoOperacao,
    this.nomeOpcao,
    this.valorMercado,
    this.valorStrike,
    this.dataExercicio,
    this.porcentagemPremio,
    this.valorPremioLiquido,
    this.percentualRetorno,
    this.percentualRetornoLiquido,
    this.situacaoMomento,
    this.valorCobertural,
    this.exercidoOperacao,
    this.corretoraOperada,
    this.valorIrrrf,
    this.dataTransacao,
    this.usuarioNome,
    this.acaoCodigo,
  });

  static double? _toDoubleNullable(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  factory Transacao.fromJson(Map<String, dynamic> json) {
    return Transacao(
      id: json['id'] is String ? int.tryParse(json['id']) : json['id'] as int?,
      usuarioId: json['usuario_id'] is String ? int.parse(json['usuario_id']) : json['usuario_id'] as int,
      acaoId: json['acao_id'] is String ? int.parse(json['acao_id']) : json['acao_id'] as int,
      tipo: json['tipo'] ?? '',
      quantidade: json['quantidade'] is String ? int.parse(json['quantidade']) : json['quantidade'] as int,
      precoUnitario: _toDouble(json['preco_unitario']),

      tipoOperacao: json['tipo_operacao'],
      nomeOpcao: json['nome_opcao'],
      valorMercado: _toDoubleNullable(json['valor_mercado']),
      valorStrike: _toDoubleNullable(json['valor_strike']),

      dataExercicio: json['data_exercicio'] != null
          ? DateTime.tryParse(json['data_exercicio'])
          : null,
      porcentagemPremio: _toDoubleNullable(json['porcentagem_premio']),
      valorPremioLiquido: _toDoubleNullable(json['valor_premio_liquido']),
      percentualRetorno: _toDoubleNullable(json['percentual_retorno']),
      percentualRetornoLiquido: _toDoubleNullable(json['percentual_retorno_liquido']),
      situacaoMomento: _toDoubleNullable(json['situacao_momento']),
      valorCobertural: _toDoubleNullable(json['valor_cobertural']),
      exercidoOperacao: json['exercido_operacao'] is String
          ? (json['exercido_operacao'] == 'true' || json['exercido_operacao'] == '1')
          : json['exercido_operacao'] as bool?,
      corretoraOperada: json['corretora_operada'],
      valorIrrrf: _toDoubleNullable(json['valor_irrf']),

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
      if (tipoOperacao != null) 'tipo_operacao': tipoOperacao,
      if (nomeOpcao != null) 'nome_opcao': nomeOpcao,
      if (valorMercado != null) 'valor_mercado': valorMercado,
      if (valorStrike != null) 'valor_strike': valorStrike,
      if (dataExercicio != null) 'data_exercicio': dataExercicio!.toIso8601String().split('T').first,
      if (porcentagemPremio != null) 'porcentagem_premio': porcentagemPremio,
      if (valorPremioLiquido != null) 'valor_premio_liquido': valorPremioLiquido,
      if (percentualRetorno != null) 'percentual_retorno': percentualRetorno,
      if (percentualRetornoLiquido != null) 'percentual_retorno_liquido': percentualRetornoLiquido,
      if (situacaoMomento != null) 'situacao_momento': situacaoMomento,
      if (valorCobertural != null) 'valor_cobertural': valorCobertural,
      if (exercidoOperacao != null) 'exercido_operacao': exercidoOperacao,
      if (corretoraOperada != null) 'corretora_operada': corretoraOperada,
      if (valorIrrrf != null) 'valor_irrf': valorIrrrf,
    };
  }
}