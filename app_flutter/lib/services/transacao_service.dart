import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/transacao.dart';
import 'auth_service.dart';

class TransacaoService {
  final http.Client client = http.Client();
  final _auth = AuthService();

  Future<Map<String, String>> _headers() async {
    final t = await _auth.getToken();
    return {'Content-Type': 'application/json', if (t != null) 'Authorization': 'Bearer $t'};
  }

  Future<List<Transacao>> listarTransacoes() async {
    final r = await client.get(Uri.parse('${ApiConfig.baseUrl}/transacoes'), headers: await _headers());
    if (r.statusCode != 200) throw Exception(r.body);
    final data = jsonDecode(r.body) as List;
    return data.map((j) => Transacao.fromJson(j)).toList();
  }

  Future<Transacao> criarTransacao(Transacao t) async {
    final body = {
      'acao_id': t.acaoId,
      'tipo': t.tipo,
      'quantidade': t.quantidade,
      'preco_unitario': t.precoUnitario,
      'tipo_operacao': t.tipoOperacao,
      'nome_opcao': t.nomeOpcao,
      'valor_mercado': t.valorMercado,
      'valor_strike': t.valorStrike,
      'data_exercicio': t.dataExercicio?.toIso8601String(),
      'porcentagem_premio': t.porcentagemPremio,
      'valor_premio_liquido': t.valorPremioLiquido,
      'percentual_retorno': t.percentualRetorno,
      'percentual_retorno_liquido': t.percentualRetornoLiquido,
      'situacao_momento': t.situacaoMomento,
      'valor_cobertural': t.valorCobertural,
      'exercido_operacao': t.exercidoOperacao,
      'corretora_operada': t.corretoraOperada,
      'valor_irrf': t.valorIrrrf,
      'data_transacao': t.dataTransacao?.toIso8601String(),
    };
    final r = await client.post(Uri.parse('${ApiConfig.baseUrl}/transacoes'), headers: await _headers(), body: jsonEncode(body));
    if (r.statusCode != 201) throw Exception(r.body);
    return Transacao.fromJson(jsonDecode(r.body));
  }

  Future<void> atualizarTransacao(int id, Transacao t) async {
    final body = { /* mesmo body do criar */ 
      'acao_id': t.acaoId,
      'tipo': t.tipo,
      'quantidade': t.quantidade,
      'preco_unitario': t.precoUnitario,
      'tipo_operacao': t.tipoOperacao,
      'nome_opcao': t.nomeOpcao,
      'valor_mercado': t.valorMercado,
      'valor_strike': t.valorStrike,
      'data_exercicio': t.dataExercicio?.toIso8601String(),
      'porcentagem_premio': t.porcentagemPremio,
      'valor_premio_liquido': t.valorPremioLiquido,
      'percentual_retorno': t.percentualRetorno,
      'percentual_retorno_liquido': t.percentualRetornoLiquido,
      'situacao_momento': t.situacaoMomento,
      'valor_cobertural': t.valorCobertural,
      'exercido_operacao': t.exercidoOperacao,
      'corretora_operada': t.corretoraOperada,
      'valor_irrf': t.valorIrrrf,
      'data_transacao': t.dataTransacao?.toIso8601String(),
    };
    final r = await client.put(Uri.parse('${ApiConfig.baseUrl}/transacoes/$id'), headers: await _headers(), body: jsonEncode(body));
    if (r.statusCode != 200) throw Exception(r.body);
  }

  Future<void> deletarTransacao(int id) async {
    final r = await client.delete(Uri.parse('${ApiConfig.baseUrl}/transacoes/$id'), headers: await _headers());
    if (r.statusCode != 204 && r.statusCode != 200) throw Exception(r.body);
  }
}