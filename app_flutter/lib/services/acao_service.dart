import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/acao.dart';

class AcaoService {
  final String endpoint = ApiConfig.acoes;

  Future<List<Acao>> listarAcoes() async {
    print('GET $endpoint');
    final resp = await http
        .get(Uri.parse(endpoint), headers: {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 10));
    print('Status: ${resp.statusCode}');
    print('Body: ${resp.body}');
    if (resp.statusCode != 200) {
      throw Exception('Falha (${resp.statusCode}) ao buscar ações: ${resp.body}');
    }
    final List data = jsonDecode(resp.body);
    return data.map((j) => Acao.fromJson(j)).toList();
  }
}
