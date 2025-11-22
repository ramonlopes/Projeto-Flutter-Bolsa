import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:bolsa_app/services/acao_service.dart';
import 'package:bolsa_app/models/acao.dart';

void main() {
  test('AcaoService.lista retorna lista de Acoes', () async {
    final mock = MockClient((req) async {
      return http.Response(
        jsonEncode([
          {
            'id': 1,
            'codigo': 'VALE3',
            'nome_empresa': 'Vale ON',
            'preco_atual': 61.80
          }
        ]),
        200,
        headers: {'content-type': 'application/json'},
      );
    });

    final service = AcaoService(client: mock, endpoint: 'http://test/acoes');
    final lista = await service.listarAcoes();
    expect(lista, isA<List<Acao>>());
    expect(lista.first.codigo, 'VALE3');
  });
}