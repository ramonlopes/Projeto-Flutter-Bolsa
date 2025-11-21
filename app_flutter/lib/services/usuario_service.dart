import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/usuario.dart';

class UsuarioService {
  final String endpoint = ApiConfig.usuarios;

  Future<List<Usuario>> listarUsuarios() async {
    print('GET usuarios -> $endpoint');
    final resp = await http.get(Uri.parse(endpoint), headers: {'Accept':'application/json'})
        .timeout(const Duration(seconds: 10));
    print('Status usuarios: ${resp.statusCode}');
    print('Body usuarios: ${resp.body}');
    if (resp.statusCode != 200) {
      throw Exception('Falha (${resp.statusCode}) ao buscar usuários: ${resp.body}');
    }
    final List data = jsonDecode(resp.body);
    return data.map((j) => Usuario.fromJson(j)).toList();
  }

  Future<Usuario> criarUsuario(Usuario usuario) async {
    final resp = await http.post(
      Uri.parse(endpoint),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode(usuario.toJsonCreate()),
    ).timeout(const Duration(seconds: 10));
    if (resp.statusCode != 201) {
      throw Exception('Erro ao criar usuário (${resp.statusCode}): ${resp.body}');
    }
    return Usuario.fromJson(jsonDecode(resp.body));
  }
}
