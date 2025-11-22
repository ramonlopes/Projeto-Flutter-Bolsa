import 'package:flutter_test/flutter_test.dart';
import 'package:bolsa_app/models/acao.dart';

void main() {
  test('Acao.fromJson mapeia nomes do banco', () {
    final json = {
      'id': 1,
      'codigo': 'PETR4',
      'nome_empresa': 'Petrobras PN',
      'preco_atual': '37.20',
    };
    final a = Acao.fromJson(json);
    expect(a.id, 1);
    expect(a.codigo, 'PETR4');
    expect(a.nomeEmpresa, 'Petrobras PN');
    expect(a.precoAtual, 37.20);
  });
}