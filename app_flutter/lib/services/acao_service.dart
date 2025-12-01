import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/acao.dart';

class AcaoPreco {
  final String codigo;
  final String simboloYahoo;
  final double preco;
  final double? variacaoPercent;
  final String moeda;
  final DateTime atualizadoEm;

  AcaoPreco({
    required this.codigo,
    required this.simboloYahoo,
    required this.preco,
    this.variacaoPercent,
    required this.moeda,
    required this.atualizadoEm,
  });

  factory AcaoPreco.fromJson(Map<String, dynamic> j) => AcaoPreco(
        codigo: j['codigo'],
        simboloYahoo: j['simboloYahoo'],
        preco: (j['preco'] as num).toDouble(),
        variacaoPercent: j['variacaoPercent'] == null ? null : (j['variacaoPercent'] as num).toDouble(),
        moeda: j['moeda'] ?? 'BRL',
        atualizadoEm: DateTime.parse(j['atualizadoEm']),
      );
}

class AcaoService {
  final http.Client client = http.Client();

  Future<List<Acao>> listarAcoes() async {
    final resp = await client
        .get(Uri.parse('${ApiConfig.baseUrl}/acoes'))
        .timeout(const Duration(seconds: 10));
    if (resp.statusCode != 200) {
      throw Exception('Erro ao listar ações: ${resp.body}');
    }
    final data = jsonDecode(resp.body) as List;
    return data.map((j) => Acao.fromJson(j as Map<String, dynamic>)).toList();
  }

  Future<Acao> criarAcao(Acao acao) async {
    final resp = await client.post(
      Uri.parse('${ApiConfig.baseUrl}/acoes'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'codigo': acao.codigo,
        'nome_empresa': acao.nomeEmpresa,
        'preco_atual': acao.precoAtual,
      }),
    ).timeout(const Duration(seconds: 10));
    if (resp.statusCode != 201) {
      throw Exception('Erro ao criar ação: ${resp.body}');
    }
    return Acao.fromJson(jsonDecode(resp.body));
  }

  Future<Acao> atualizarAcao(int id, Acao acao) async {
    final resp = await client.put(
      Uri.parse('${ApiConfig.baseUrl}/acoes/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'codigo': acao.codigo,
        'nome_empresa': acao.nomeEmpresa,
        'preco_atual': acao.precoAtual,
      }),
    ).timeout(const Duration(seconds: 10));
    if (resp.statusCode != 200) {
      throw Exception('Erro ao atualizar ação: ${resp.body}');
    }
    return Acao.fromJson(jsonDecode(resp.body));
  }

  Future<void> deletarAcao(int id) async {
    final resp = await client
        .delete(Uri.parse('${ApiConfig.baseUrl}/acoes/$id'))
        .timeout(const Duration(seconds: 10));
    if (resp.statusCode != 204 && resp.statusCode != 200) {
      throw Exception('Erro ao deletar ação: ${resp.body}');
    }
  }

  Future<AcaoPreco> obterPreco(String codigo) async {
    final resp = await client
        .get(Uri.parse('${ApiConfig.baseUrl}/acoes/preco/$codigo'))
        .timeout(const Duration(seconds: 10));
    if (resp.statusCode != 200) {
      throw Exception('Erro ao obter preço: ${resp.body}');
    }
    return AcaoPreco.fromJson(jsonDecode(resp.body));
  }
}
