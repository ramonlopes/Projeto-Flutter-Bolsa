import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class Usuario {
  final int id;
  final String nome;
  final String email;
  Usuario({required this.id, required this.nome, required this.email});
  factory Usuario.fromJson(Map<String, dynamic> j) => Usuario(
        id: j['id'] as int,
        nome: j['nome'] as String,
        email: j['email'] as String,
      );
}

class AuthService {
  final http.Client client = http.Client();
  static const _tokenKey = 'auth_token';
  static const _userKey = 'auth_user';

  Future<void> login(String email, String senha) async {
    final resp = await client.post(
      Uri.parse('${ApiConfig.baseUrl}/usuarios/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'senha': senha}),
    ).timeout(const Duration(seconds: 10));

    if (resp.statusCode != 200) {
      throw Exception(jsonDecode(resp.body)['error'] ?? 'Erro ao fazer login');
    }

    final data = jsonDecode(resp.body);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, data['token']);
    await prefs.setString(_userKey, jsonEncode(data['usuario']));
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<Usuario?> getUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_userKey);
    if (json == null) return null;
    return Usuario.fromJson(jsonDecode(json));
  }

  Future<bool> isLoggedIn() async {
    return await getToken() != null;
  }

  Future<void> registrar(String nome, String email, String senha) async {
    final resp = await client.post(
      Uri.parse('${ApiConfig.baseUrl}/usuarios'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'nome': nome, 'email': email, 'senha': senha}),
    ).timeout(const Duration(seconds: 10));

    if (resp.statusCode != 201) {
      throw Exception(jsonDecode(resp.body)['error'] ?? 'Erro ao registrar');
    }
  }

  Future<Map<String, dynamic>> signInWithGoogle(String idToken) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/usuarios/google');
    final resp = await http.post(
      url,
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode({'idToken': idToken}),
    ).timeout(const Duration(seconds: 10));
    if (resp.statusCode != 200) {
      throw Exception('Falha na autenticação Google: ${resp.statusCode} ${resp.body}');
    }
    return jsonDecode(resp.body) as Map<String, dynamic>;
  }
}