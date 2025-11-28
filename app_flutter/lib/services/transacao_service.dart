import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/transacao.dart';

class TransacaoService {
  TransacaoService({http.Client? client, String? endpoint})
      : client = client ?? http.Client(),
        endpoint = endpoint ?? '${ApiConfig.baseUrl}/transacoes';

  final http.Client client;
  final String endpoint;

  Future<List<Transacao>> listarTransacoes() async {
    debugPrint('GET $endpoint');
    final resp = await client
        .get(Uri.parse(endpoint), headers: {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 10));
    debugPrint('Status: ${resp.statusCode}');
    debugPrint('Body: ${resp.body}');
    if (resp.statusCode != 200) {
      throw Exception('Falha ao buscar transações: ${resp.body}');
    }
    final List data = jsonDecode(resp.body);
    return data.map((j) => Transacao.fromJson(j)).toList();
  }

  Future<Transacao> criarTransacao(Transacao transacao) async {
    final resp = await client
        .post(
          Uri.parse(endpoint),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: jsonEncode(transacao.toJsonCreate()),
        )
        .timeout(const Duration(seconds: 10));
    if (resp.statusCode != 201) {
      throw Exception('Erro ao criar transação: ${resp.body}');
    }
    return Transacao.fromJson(jsonDecode(resp.body));
  }

  Future<Transacao> atualizarTransacao(int id, Transacao transacao) async {
    final resp = await client
        .put(
          Uri.parse('$endpoint/$id'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: jsonEncode(transacao.toJsonCreate()),
        )
        .timeout(const Duration(seconds: 10));
    if (resp.statusCode != 200) {
      throw Exception('Erro ao atualizar transação: ${resp.body}');
    }
    return Transacao.fromJson(jsonDecode(resp.body));
  }

  Future<void> deletarTransacao(int id) async {
    final resp = await client
        .delete(Uri.parse('$endpoint/$id'))
        .timeout(const Duration(seconds: 10));
    if (resp.statusCode != 204 && resp.statusCode != 200) {
      throw Exception('Erro ao deletar transação: ${resp.body}');
    }
  }
}