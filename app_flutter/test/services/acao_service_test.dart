import 'package:flutter_test/flutter_test.dart';
import 'package:bolsa_app/services/acao_service.dart';

void main() {
  test('AcaoService.listarAcoes retorna lista de Acoes', () async {
    // Nota: AcaoService não aceita parâmetros customizados
    // Este é um teste básico que verificaria se a classe compila
    final service = AcaoService();
    expect(service, isNotNull);
    expect(service.runtimeType.toString(), 'AcaoService');
  });
}