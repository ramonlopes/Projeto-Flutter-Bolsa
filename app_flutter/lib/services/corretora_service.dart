import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/corretora.dart';
import '../services/auth_service.dart'; // adicione

class CorretoraService {
  final http.Client client = http.Client();
  final _auth = AuthService();

  Future<Map<String, String>> _authHeaders() async {
    final token = await _auth.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<Corretora>> listar() async {
    final resp = await client.get(
      Uri.parse('${ApiConfig.baseUrl}/corretoras'),
      headers: await _authHeaders(),
    );
    if (resp.statusCode != 200) throw Exception('Erro ao listar: ${resp.body}');
    final data = jsonDecode(resp.body) as List;
    return data.map((j)=>Corretora.fromJson(j)).toList();
  }

  Future<Corretora> criar(Corretora c) async {
    final resp = await client.post(
      Uri.parse('${ApiConfig.baseUrl}/corretoras'),
      headers: await _authHeaders(),
      body: jsonEncode(c.toJson()),
    );
    if (resp.statusCode != 201) throw Exception('Erro ao criar: ${resp.body}');
    return Corretora.fromJson(jsonDecode(resp.body));
  }

  Future<Corretora> atualizar(int id, Corretora c) async {
    final resp = await client.put(
      Uri.parse('${ApiConfig.baseUrl}/corretoras/$id'),
      headers: await _authHeaders(),
      body: jsonEncode(c.toJson()),
    );
    if (resp.statusCode != 200) throw Exception('Erro ao atualizar: ${resp.body}');
    return Corretora.fromJson(jsonDecode(resp.body));
  }

  Future<void> deletar(int id) async {
    final resp = await client.delete(
      Uri.parse('${ApiConfig.baseUrl}/corretoras/$id'),
      headers: await _authHeaders(),
    );
    if (resp.statusCode != 200 && resp.statusCode != 204) {
      throw Exception('Erro ao excluir: ${resp.body}');
    }
  }
}