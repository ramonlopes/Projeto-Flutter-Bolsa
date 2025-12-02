import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/usuario.dart'; // use o modelo único

class AuthService {
  final http.Client client = http.Client();
  static const _tokenKey = 'auth_token';
  static const _userKey = 'auth_user';

  Future<void> login(String email, String senha) async {
    final resp = await client.post(
      Uri.parse('${ApiConfig.baseUrl}/usuarios/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'senha': senha}),
    );
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
    final raw = prefs.getString(_userKey);
    if (raw == null) return null;
    return Usuario.fromJson(jsonDecode(raw));
  }

  Future<bool> isLoggedIn() async {
    return (await getToken()) != null;
  }
}