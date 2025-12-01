import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/acao_service.dart';
import '../models/acao.dart';
import 'acao_form_screen.dart';

class AcoesScreen extends StatefulWidget {
  const AcoesScreen({super.key});

  @override
  State<AcoesScreen> createState() => _AcoesScreenState();
}

class _AcoesScreenState extends State<AcoesScreen> {
  late Future<List<Acao>> _futuro;
  final service = AcaoService();
  final _currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  @override
  void initState() {
    super.initState();
    _futuro = service.listarAcoes();
  }

  void _recarregar() {
    setState(() => _futuro = service.listarAcoes());
  }

  Future<void> _confirmarExclusao(Acao a) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir ação?'),
        content: Text('Confirma excluir ${a.codigo} - ${a.nomeEmpresa}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Excluir')),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await service.deletarAcao(a.id);
      if (!mounted) return;
      messenger.showSnackBar(const SnackBar(content: Text('Ação excluída')));
      _recarregar();
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text('Erro ao excluir: $e')));
    }
  }

  Widget _card(Acao a) {
    return Card(
      elevation: 1.5,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: Colors.blue.shade100,
          child: Text(
            a.codigo.substring(0, 1).toUpperCase(),
            style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(a.codigo, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(a.nomeEmpresa),
            const SizedBox(height: 4),
            Text('Preço: ${_currency.format(a.precoAtual)}',
                style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.w600)),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (v) async {
            if (v == 'edit') {
              final ok = await Navigator.push<bool>(
                context,
                MaterialPageRoute(builder: (_) => AcaoFormScreen(acao: a)),
              );
              if (ok == true) _recarregar();
            } else if (v == 'delete') {
              _confirmarExclusao(a);
            }
          },
          itemBuilder: (ctx) => const [
            PopupMenuItem(value: 'edit', child: Text('Editar')),
            PopupMenuItem(value: 'delete', child: Text('Excluir')),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ações')),
      body: RefreshIndicator(
        onRefresh: () async => _recarregar(),
        child: FutureBuilder<List<Acao>>(
          future: _futuro,
          builder: (ctx, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 12),
                      Text('Erro ao carregar: ${snap.error}', textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: _recarregar,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                ),
              );
            }
            final lista = snap.data ?? [];
            if (lista.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.show_chart, size: 64, color: Colors.grey.shade500),
                      const SizedBox(height: 12),
                      const Text('Nenhuma ação cadastrada'),
                      const SizedBox(height: 8),
                      Text('Toque em "Adicionar" para cadastrar a primeira ação.',
                          style: TextStyle(color: Colors.grey.shade600), textAlign: TextAlign.center),
                    ],
                  ),
                ),
              );
            }
            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: lista.length,
              itemBuilder: (_, i) => _card(lista[i]),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final ok = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const AcaoFormScreen()),
          );
          if (ok == true) _recarregar();
        },
        icon: const Icon(Icons.add),
        label: const Text('Adicionar'),
      ),
    );
  }
}
