import 'dart:convert';
import 'package:flutter/foundation.dart'; // debugPrint
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/acao.dart';

class AcaoService {
  AcaoService({http.Client? client, String? endpoint})
      : client = client ?? http.Client(),
        endpoint = endpoint ?? ApiConfig.acoes;

  final http.Client client;
  final String endpoint;

  Future<List<Acao>> listarAcoes() async {
    debugPrint('GET $endpoint');
    final resp = await client
        .get(Uri.parse(endpoint), headers: {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 10));
    debugPrint('Status: ${resp.statusCode}');
    debugPrint('Body: ${resp.body}');
    if (resp.statusCode != 200) {
      throw Exception('Falha (${resp.statusCode}) ao buscar ações: ${resp.body}');
    }
    final List data = jsonDecode(resp.body);
    return data.map((j) => Acao.fromJson(j)).toList();
  }
}
