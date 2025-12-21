import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/corretora.dart';
import '../services/corretora_service.dart';
import 'corretora_form_screen.dart';

class CorretorasScreen extends StatefulWidget {
  const CorretorasScreen({super.key});

  @override
  State<CorretorasScreen> createState() => _CorretorasScreenState();
}

class _CorretorasScreenState extends State<CorretorasScreen> {
  final _service = CorretoraService();
  late Future<List<Corretora>> _futuro;
  final _currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  @override
  void initState() {
    super.initState();
    _futuro = _service.listar();
  }

  void _recarregar() {
    setState(() => _futuro = _service.listar());
  }

  Future<void> _excluir(Corretora c) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir corretora'),
        content: Text('Deseja excluir "${c.nome}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Excluir')),
        ],
      ),
    ) ?? false;

    if (!ok) return;

    final id = c.id;
    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Corretora sem ID. Não é possível excluir.')),
      );
      return;
    }

    await _service.deletar(id); // id é int
    _recarregar();
  }

  Widget _cardCorretora(Corretora c) {
    final theme = Theme.of(context);
    return Card(
      elevation: 6,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      shadowColor: theme.colorScheme.primary.withOpacity(0.25),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          final ok = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => CorretoraFormScreen(corretora: c)),
          );
          if (ok == true) _recarregar();
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.account_balance, color: Colors.teal, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.nome, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    if (c.cnpj != null && c.cnpj!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text('CNPJ: ${c.cnpj}', style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                    ],
                    if (c.taxaCorretagem != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.attach_money, size: 16, color: Colors.orange.shade700),
                          const SizedBox(width: 4),
                          Text(
                            'Taxa: ${_currency.format(c.taxaCorretagem)}',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (v) async {
                  if (v == 'edit') {
                    final ok = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(builder: (_) => CorretoraFormScreen(corretora: c)),
                    );
                    if (ok == true) _recarregar();
                  } else if (v == 'delete') {
                    _excluir(c);
                  }
                },
                itemBuilder: (ctx) => const [
                  PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text('Editar')])),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(children: [Icon(Icons.delete, size: 18, color: Colors.red), SizedBox(width: 8), Text('Excluir', style: TextStyle(color: Colors.red))]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal, Colors.teal.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.teal.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: const [
          Icon(Icons.account_balance, color: Colors.white),
          SizedBox(width: 10),
          Text('Minhas Corretoras', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.withOpacity(0.08), Colors.teal.shade700.withOpacity(0.08)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: RefreshIndicator(
          onRefresh: () async => _recarregar(),
          child: FutureBuilder<List<Corretora>>(
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
                        Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                        const SizedBox(height: 12),
                        Text('Erro ao carregar: ${snap.error}', textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(onPressed: _recarregar, icon: const Icon(Icons.refresh), label: const Text('Tentar novamente')),
                      ],
                    ),
                  ),
                );
              }
              final corretoras = snap.data ?? [];
              if (corretoras.isEmpty) {
                return ListView(
                  children: [
                    _header(),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.inbox, size: 80, color: Colors.grey.shade300),
                          const SizedBox(height: 12),
                          Text('Nenhuma corretora cadastrada', style: TextStyle(fontSize: 18, color: Colors.grey.shade700, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text('Toque em + para adicionar sua primeira corretora', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600)),
                        ],
                      ),
                    ),
                  ],
                );
              }

              return ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: corretoras.length,
                itemBuilder: (ctx, i) {
                  final c = corretoras[i];
                  return Card(
                    elevation: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    shadowColor: theme.colorScheme.primary.withOpacity(0.25),
                    child: ListTile(
                      title: Text(c.nome),
                      subtitle: Text(c.cnpj ?? ''),
                      trailing: Text(
                        _currency.format(c.saldo ?? 0),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onTap: () async {
                        final ok = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(builder: (_) => CorretoraFormScreen(corretora: c)),
                        );
                        if (ok == true) _recarregar();
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
      appBar: AppBar(
        title: const Text('Corretoras'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _recarregar),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final ok = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => const CorretoraFormScreen()));
          if (ok == true) _recarregar();
        },
        icon: const Icon(Icons.add),
        label: const Text('Nova Corretora'),
        backgroundColor: Colors.teal,
      ),
    );
  }
}