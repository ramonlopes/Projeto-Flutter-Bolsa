import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/transacao.dart';
import 'auth_service.dart';

class TransacaoService {
  final http.Client client = http.Client();
  final _authService = AuthService();

  Future<Map<String, String>> _headers() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<Transacao>> listarTransacoes() async {
    final resp = await client
        .get(Uri.parse('${ApiConfig.baseUrl}/transacoes'), headers: await _headers())
        .timeout(const Duration(seconds: 10));
    if (resp.statusCode != 200) {
      throw Exception('Erro ao listar: ${resp.body}');
    }
    final data = jsonDecode(resp.body) as List;
    return data.map((j) => Transacao.fromJson(j)).toList();
  }

  Future<Transacao> criarTransacao(Transacao t) async {
    final resp = await client.post(
      Uri.parse('${ApiConfig.baseUrl}/transacoes'),
      headers: await _headers(),
      body: jsonEncode(t.toJsonCreate()),
    ).timeout(const Duration(seconds: 10));
    if (resp.statusCode != 201) {
      throw Exception('Erro ao criar: ${resp.body}');
    }
    return Transacao.fromJson(jsonDecode(resp.body));
  }

  Future<void> atualizarTransacao(int id, Transacao t) async {
    final resp = await client.put(
      Uri.parse('${ApiConfig.baseUrl}/transacoes/$id'),
      headers: await _headers(),
      body: jsonEncode(t.toJsonCreate()),
    ).timeout(const Duration(seconds: 10));
    if (resp.statusCode != 200) {
      throw Exception('Erro ao atualizar: ${resp.body}');
    }
  }

  Future<void> deletarTransacao(int id) async {
    final resp = await client
        .delete(Uri.parse('${ApiConfig.baseUrl}/transacoes/$id'), headers: await _headers())
        .timeout(const Duration(seconds: 10));
    if (resp.statusCode != 204 && resp.statusCode != 200) {
      throw Exception('Erro ao deletar: ${resp.body}');
    }
  }
}