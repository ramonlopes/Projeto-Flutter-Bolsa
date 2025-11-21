import 'package:flutter/material.dart';
import '../services/acao_service.dart';
import '../models/acao.dart';

class AcoesScreen extends StatefulWidget {
  const AcoesScreen({super.key});

  @override
  State<AcoesScreen> createState() => _AcoesScreenState();
}

class _AcoesScreenState extends State<AcoesScreen> {
  late Future<List<Acao>> _futuro;
  final service = AcaoService();

  @override
  void initState() {
    super.initState();
    _futuro = service.listarAcoes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ações')),
      body: FutureBuilder<List<Acao>>(
        future: _futuro,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Erro: ${snap.error}'));
          }
          final lista = snap.data ?? [];
          if (lista.isEmpty) {
            return const Center(child: Text('Nenhuma ação encontrada'));
          }
          return ListView.builder(
            itemCount: lista.length,
            itemBuilder: (_, i) {
              final a = lista[i];
              return ListTile(
                title: Text(a.codigo),
                subtitle: Text(a.nomeEmpresa),
                trailing: Text(
                  a.precoAtual <= 0 ? '0.00' : a.precoAtual.toStringAsFixed(2),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
