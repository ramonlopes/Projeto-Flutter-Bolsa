import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:bolsa_app/services/usuario_service.dart';
import 'package:bolsa_app/models/usuario.dart';

void main() {
  test('UsuarioService.listar retorna usuários', () async {
    final mock = MockClient((req) async {
      return http.Response(
        jsonEncode([
          {'id': 1, 'nome': 'Alice', 'email': 'alice@mail.com'}
        ]),
        200,
        headers: {'content-type': 'application/json'},
      );
    });
    final service = UsuarioService(client: mock, endpoint: 'http://test/usuarios');
    final lista = await service.listarUsuarios();
    expect(lista.first.nome, 'Alice');
  });

  test('UsuarioService.criar cria e retorna usuário', () async {
    final mock = MockClient((req) async {
      if (req.method == 'POST') {
        final body = jsonDecode(req.body) as Map<String, dynamic>;
        return http.Response(
          jsonEncode({'id': 2, 'nome': body['nome'], 'email': body['email']}),
          201,
          headers: {'content-type': 'application/json'},
        );
      }
      return http.Response('Not Found', 404);
    });
    final service = UsuarioService(client: mock, endpoint: 'http://test/usuarios');
    final novo = await service.criarUsuario(
      Usuario(nome: 'Bob', email: 'bob@mail.com', senha: '123'),
    );
    expect(novo.email, 'bob@mail.com');
  });
}