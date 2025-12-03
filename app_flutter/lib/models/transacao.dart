class Transacao {
  final int? id;
  final int usuarioId;
  final int acaoId;
  final String tipo; // compra | venda
  final int quantidade;
  final double precoUnitario;

  // Derivativos (Opções)
  final String? tipoOperacao; // PUT | CALL
  final String? nomeOpcao;
  final double? valorMercado;
  final double? valorStrike;
  final DateTime? dataExercicio;

  // Financeiro
  final double? porcentagemPremio;
  final double? valorPremioLiquido;
  final double? percentualRetorno;
  final double? percentualRetornoLiquido;
  final double? situacaoMomento;
  final double? valorCobertural;
  final bool? exercidoOperacao;
  final String? corretoraOperada;
  final double? valorIrrrf;

  // Metadados
  final DateTime? dataTransacao;
  final String? acaoCodigo; // usado em listagens se o backend retornar

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
    this.acaoCodigo,
  });

  factory Transacao.fromJson(Map<String, dynamic> j) {
    double? _toDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v.replaceAll(',', '.'));
      return null;
    }

    int _toInt(dynamic v) {
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    DateTime? _toDate(dynamic v) {
      if (v == null) return null;
      if (v is DateTime) return v;
      if (v is String && v.isNotEmpty) {
        try {
          return DateTime.parse(v);
        } catch (_) {
          // formato dd/MM/yyyy
          final parts = v.split('/');
          if (parts.length == 3) {
            final d = int.tryParse(parts[0]);
            final m = int.tryParse(parts[1]);
            final y = int.tryParse(parts[2]);
            if (d != null && m != null && y != null) return DateTime(y, m, d);
          }
        }
      }
      return null;
    }

    return Transacao(
      id: j['id'] as int?,
      usuarioId: _toInt(j['usuario_id'] ?? j['usuarioId']),
      acaoId: _toInt(j['acao_id'] ?? j['acaoId']),
      tipo: (j['tipo'] ?? '').toString(),
      quantidade: _toInt(j['quantidade']),
      precoUnitario: _toDouble(j['preco_unitario'] ?? j['precoUnitario']) ?? 0,
      tipoOperacao: j['tipo_operacao'] ?? j['tipoOperacao'],
      nomeOpcao: j['nome_opcao'] ?? j['nomeOpcao'],
      valorMercado: _toDouble(j['valor_mercado'] ?? j['valorMercado']),
      valorStrike: _toDouble(j['valor_strike'] ?? j['valorStrike']),
      dataExercicio: _toDate(j['data_exercicio'] ?? j['dataExercicio']),
      porcentagemPremio: _toDouble(j['porcentagem_premio'] ?? j['porcentagemPremio']),
      valorPremioLiquido: _toDouble(j['valor_premio_liquido'] ?? j['valorPremioLiquido']),
      percentualRetorno: _toDouble(j['percentual_retorno'] ?? j['percentualRetorno']),
      percentualRetornoLiquido: _toDouble(j['percentual_retorno_liquido'] ?? j['percentualRetornoLiquido']),
      situacaoMomento: _toDouble(j['situacao_momento'] ?? j['situacaoMomento']),
      valorCobertural: _toDouble(j['valor_cobertural'] ?? j['valorCobertural']),
      exercidoOperacao: (j['exercido_operacao'] ?? j['exercidoOperacao']) as bool?,
      corretoraOperada: j['corretora_operada'] ?? j['corretoraOperada'],
      valorIrrrf: _toDouble(j['valor_irrf'] ?? j['valorIrrrf']),
      dataTransacao: _toDate(j['data_transacao'] ?? j['dataTransacao']),
      acaoCodigo: j['acao_codigo'] ?? j['acaoCodigo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'usuario_id': usuarioId,
      'acao_id': acaoId,
      'tipo': tipo,
      'quantidade': quantidade,
      'preco_unitario': precoUnitario,
      if (tipoOperacao != null) 'tipo_operacao': tipoOperacao,
      if (nomeOpcao != null) 'nome_opcao': nomeOpcao,
      if (valorMercado != null) 'valor_mercado': valorMercado,
      if (valorStrike != null) 'valor_strike': valorStrike,
      if (dataExercicio != null) 'data_exercicio': dataExercicio!.toIso8601String(),
      if (porcentagemPremio != null) 'porcentagem_premio': porcentagemPremio,
      if (valorPremioLiquido != null) 'valor_premio_liquido': valorPremioLiquido,
      if (percentualRetorno != null) 'percentual_retorno': percentualRetorno,
      if (percentualRetornoLiquido != null) 'percentual_retorno_liquido': percentualRetornoLiquido,
      if (situacaoMomento != null) 'situacao_momento': situacaoMomento,
      if (valorCobertural != null) 'valor_cobertural': valorCobertural,
      if (exercidoOperacao != null) 'exercido_operacao': exercidoOperacao,
      if (corretoraOperada != null) 'corretora_operada': corretoraOperada,
      if (valorIrrrf != null) 'valor_irrf': valorIrrrf,
      if (dataTransacao != null) 'data_transacao': dataTransacao!.toIso8601String(),
      if (acaoCodigo != null) 'acao_codigo': acaoCodigo,
    };
  }

  Transacao copyWith({
    int? id,
    int? usuarioId,
    int? acaoId,
    String? tipo,
    int? quantidade,
    double? precoUnitario,
    String? tipoOperacao,
    String? nomeOpcao,
    double? valorMercado,
    double? valorStrike,
    DateTime? dataExercicio,
    double? porcentagemPremio,
    double? valorPremioLiquido,
    double? percentualRetorno,
    double? percentualRetornoLiquido,
    double? situacaoMomento,
    double? valorCobertural,
    bool? exercidoOperacao,
    String? corretoraOperada,
    double? valorIrrrf,
    DateTime? dataTransacao,
    String? acaoCodigo,
  }) {
    return Transacao(
      id: id ?? this.id,
      usuarioId: usuarioId ?? this.usuarioId,
      acaoId: acaoId ?? this.acaoId,
      tipo: tipo ?? this.tipo,
      quantidade: quantidade ?? this.quantidade,
      precoUnitario: precoUnitario ?? this.precoUnitario,
      tipoOperacao: tipoOperacao ?? this.tipoOperacao,
      nomeOpcao: nomeOpcao ?? this.nomeOpcao,
      valorMercado: valorMercado ?? this.valorMercado,
      valorStrike: valorStrike ?? this.valorStrike,
      dataExercicio: dataExercicio ?? this.dataExercicio,
      porcentagemPremio: porcentagemPremio ?? this.porcentagemPremio,
      valorPremioLiquido: valorPremioLiquido ?? this.valorPremioLiquido,
      percentualRetorno: percentualRetorno ?? this.percentualRetorno,
      percentualRetornoLiquido: percentualRetornoLiquido ?? this.percentualRetornoLiquido,
      situacaoMomento: situacaoMomento ?? this.situacaoMomento,
      valorCobertural: valorCobertural ?? this.valorCobertural,
      exercidoOperacao: exercidoOperacao ?? this.exercidoOperacao,
      corretoraOperada: corretoraOperada ?? this.corretoraOperada,
      valorIrrrf: valorIrrrf ?? this.valorIrrrf,
      dataTransacao: dataTransacao ?? this.dataTransacao,
      acaoCodigo: acaoCodigo ?? this.acaoCodigo,
    );
  }
}