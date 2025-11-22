import 'dart:convert';
import 'package:flutter/foundation.dart'; // debugPrint
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/usuario.dart';

class UsuarioService {
  UsuarioService({http.Client? client, String? endpoint})
      : client = client ?? http.Client(),
        endpoint = endpoint ?? ApiConfig.usuarios;

  final http.Client client;
  final String endpoint;

  Future<List<Usuario>> listarUsuarios() async {
    debugPrint('GET usuarios -> $endpoint');
    final resp = await client
        .get(Uri.parse(endpoint), headers: {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 10));
    debugPrint('Status usuarios: ${resp.statusCode}');
    debugPrint('Body usuarios: ${resp.body}');
    if (resp.statusCode != 200) {
      throw Exception('Falha (${resp.statusCode}) ao buscar usuários: ${resp.body}');
    }
    final List data = jsonDecode(resp.body);
    return data.map((j) => Usuario.fromJson(j)).toList();
  }

  Future<Usuario> criarUsuario(Usuario usuario) async {
    final resp = await client
        .post(
          Uri.parse(endpoint),
          headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
          body: jsonEncode(usuario.toJsonCreate()),
        )
        .timeout(const Duration(seconds: 10));
    if (resp.statusCode != 201) {
      throw Exception('Erro ao criar usuário (${resp.statusCode}): ${resp.body}');
    }
    return Usuario.fromJson(jsonDecode(resp.body));
  }
}
