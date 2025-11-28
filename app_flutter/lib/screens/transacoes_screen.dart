import 'package:flutter/material.dart';
import '../services/transacao_service.dart';
import '../models/transacao.dart';
import 'transacao_form_screen.dart';

class TransacoesScreen extends StatefulWidget {
  const TransacoesScreen({super.key});

  @override
  State<TransacoesScreen> createState() => _TransacoesScreenState();
}

class _TransacoesScreenState extends State<TransacoesScreen> {
  late Future<List<Transacao>> _futuro;
  final service = TransacaoService();

  @override
  void initState() {
    super.initState();
    _futuro = service.listarTransacoes();
  }

  void _recarregar() {
    setState(() {
      _futuro = service.listarTransacoes();
    });
  }

  Future<void> _confirmarExclusao(Transacao transacao) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text(
            'Deseja excluir a transação ${transacao.tipo} de ${transacao.acaoCodigo ?? "ação ${transacao.acaoId}"}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmar != true || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      await service.deletarTransacao(transacao.id!);
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Transação excluída')),
      );
      _recarregar();
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Erro ao excluir: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transações')),
      body: FutureBuilder<List<Transacao>>(
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
            return const Center(child: Text('Nenhuma transação'));
          }
          return ListView.builder(
            itemCount: lista.length,
            itemBuilder: (_, i) {
              final t = lista[i];
              return ListTile(
                title: Text(
                    '${t.tipo.toUpperCase()} - ${t.acaoCodigo ?? "Ação ${t.acaoId}"}'),
                subtitle: Text(
                    '${t.quantidade} un. @ ${t.precoUnitario.toStringAsFixed(2)} - ${t.usuarioNome ?? "User ${t.usuarioId}"}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      t.dataTransacao != null
                          ? '${t.dataTransacao!.day}/${t.dataTransacao!.month}/${t.dataTransacao!.year}'
                          : '',
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () async {
                        final resultado = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TransacaoFormScreen(transacao: t),
                          ),
                        );
                        if (resultado == true) {
                          _recarregar();
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _confirmarExclusao(t),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final resultado = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const TransacaoFormScreen()),
          );
          if (resultado == true) {
            _recarregar();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}