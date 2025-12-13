import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class YahooFinanceService {
  final http.Client client = http.Client();

  String _withSuffix(String codigo) {
    final c = codigo.toUpperCase().trim();
    return c.contains('.') ? c : '$c.SA';
  }

  Future<double?> obterCotacao(String codigo) async {
    final simbolo = _withSuffix(codigo);
    final url = Uri.parse('${ApiConfig.baseUrl}/yahoo/cotacao/$simbolo');
    try {
      final resp = await client.get(url).timeout(const Duration(seconds: 8));
      if (resp.statusCode != 200) {
        print('Yahoo  HTTP ${resp.statusCode} para $simbolo');
        return await _fallbackBrapi(simbolo);
      }
      final data = jsonDecode(resp.body);
      final preco = data['preco'];
      if (preco is num) return preco.toDouble();
      return await _fallbackBrapi(simbolo);
    } catch (e) {
      print('Yahoo erro $simbolo: $e');
      return await _fallbackBrapi(simbolo);
    }
  }

  Future<Map<String, double>> obterCotacoes(List<String> codigos) async {
    if (codigos.isEmpty) return {};
    final simbolos = codigos.map(_withSuffix).toList();
    final url = Uri.parse('${ApiConfig.baseUrl}/yahoo/cotacoes');
    try {
      final resp = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'simbolos': simbolos}),
      ).timeout(const Duration(seconds: 12));
      if (resp.statusCode != 200) {
        print('Yahoo lote HTTP ${resp.statusCode}');
        return await _fallbackBrapiLote(simbolos);
      }
      final data = jsonDecode(resp.body) as List<dynamic>;
      final out = <String, double>{};
      for (final item in data) {
        final s = item['simbolo']?.toString();
        final p = item['preco'];
        if (s != null && p is num) out[s] = p.toDouble();
      }
      // completa com fallback se faltar
      final faltantes = simbolos.where((s) => !out.containsKey(s)).toList();
      if (faltantes.isNotEmpty) {
        final fb = await _fallbackBrapiLote(faltantes);
        out.addAll(fb);
      }
      return out;
    } catch (e) {
      print('Yahoo lote erro: $e');
      return await _fallbackBrapiLote(simbolos);
    }
  }

  Future<double?> _fallbackBrapi(String simbolo) async {
    try {
      final clean = simbolo.replaceAll('.SA', '');
      final url = Uri.parse('https://brapi.dev/api/quote/$clean');
      final resp = await client.get(url).timeout(const Duration(seconds: 6));
      if (resp.statusCode != 200) return null;
      final data = jsonDecode(resp.body);
      final result = (data['results'] as List?)?.firstOrNull;
      final preco = result?['regularMarketPrice'];
      return preco is num ? preco.toDouble() : null;
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, double>> _fallbackBrapiLote(List<String> simbolos) async {
    try {
      final cleaned = simbolos.map((s) => s.replaceAll('.SA', '')).toList();
      final url = Uri.parse('https://brapi.dev/api/quote/${cleaned.join(',')}');
      final resp = await client.get(url).timeout(const Duration(seconds: 10));
      if (resp.statusCode != 200) return {};
      final data = jsonDecode(resp.body);
      final results = (data['results'] as List?) ?? [];
      final out = <String, double>{};
      for (final r in results) {
        final s = r['symbol']?.toString();
        final p = r['regularMarketPrice'];
        if (s != null && p is num) out['${s.toUpperCase()}.SA'] = p.toDouble();
      }
      return out;
    } catch (_) {
      return {};
    }
  }

  void dispose() => client.close();
}