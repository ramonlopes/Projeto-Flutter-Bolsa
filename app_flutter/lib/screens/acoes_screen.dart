import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/acao.dart';
import '../services/acao_service.dart';
import '../services/yahoo_finance_service.dart';
import 'acao_form_screen.dart';

class AcoesScreen extends StatefulWidget {
  const AcoesScreen({super.key});

  @override
  State<AcoesScreen> createState() => _AcoesScreenState();
}

class _AcoesScreenState extends State<AcoesScreen> {
  final _service = AcaoService();
  final _yahooService = YahooFinanceService();
  late Future<List<Acao>> _futuro;
  final _currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  
  // Cache de cotações
  final Map<String, double> _cotacoes = {};
  bool _carregandoCotacoes = false;

  @override
  void initState() {
    super.initState();
    _futuro = _service.listarAcoes();
    _carregarCotacoes();
  }

  void _recarregar() {
    setState(() {
      _futuro = _service.listarAcoes();
      _cotacoes.clear();
    });
    _carregarCotacoes();
  }

  Future<void> _carregarCotacoes() async {
    setState(() => _carregandoCotacoes = true);
    try {
      final acoes = await _futuro;
      final simbolos = acoes.map((a) => a.codigo).toList();
      final precos = await _yahooService.obterCotacoes(simbolos);
      if (mounted) {
        setState(() {
        _cotacoes.addAll(precos);
        _carregandoCotacoes = false;
      });
      }
    } catch (e) {
      if (mounted) setState(() => _carregandoCotacoes = false);
    }
  }

  Future<void> _excluir(Acao a) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Excluir ação?'),
        content: Text('Confirma excluir ${a.codigo} - ${a.nomeEmpresa}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await _service.deletarAcao(a.id);
      messenger.showSnackBar(SnackBar(
        content: const Text('Ação excluída'),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
      ));
      _recarregar();
    } catch (e) {
      messenger.showSnackBar(SnackBar(
        content: Text('Erro ao excluir: $e'),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  Future<void> _editarAcao(Acao acao) async {
    final ok = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => AcaoFormScreen(acao: acao)),
    );
    if (ok == true) _recarregar();
  }

  Widget _cardAcao(Acao a) {
    final theme = Theme.of(context);
    final codigoYahoo = a.codigo.toUpperCase().contains('.') 
        ? a.codigo.toUpperCase() 
        : '${a.codigo.toUpperCase()}.SA';
    final cotacao = _cotacoes[codigoYahoo];
    
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
            MaterialPageRoute(builder: (_) => AcaoFormScreen(acao: a)),
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
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.show_chart, color: theme.colorScheme.primary, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(a.codigo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(a.nomeEmpresa, style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          _carregandoCotacoes ? Icons.update : Icons.attach_money,
                          size: 16,
                          color: Colors.green.shade700,
                        ),
                        const SizedBox(width: 4),
                        if (_carregandoCotacoes)
                          SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.grey.shade600),
                          )
                        else if (cotacao != null)
                          Text(
                            _currency.format(cotacao),
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                          )
                        else
                          Text(
                            a.precoAtual != null ? _currency.format(a.precoAtual) : 'N/D',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        if (cotacao != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: const [
                                Icon(Icons.wifi, size: 10, color: Colors.green),
                                SizedBox(width: 2),
                                Text(
                                  'Tempo real',
                                  style: TextStyle(fontSize: 9, color: Colors.green, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (v) async {
                  if (v == 'edit') {
                    final ok = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(builder: (_) => AcaoFormScreen(acao: a)),
                    );
                    if (ok == true) _recarregar();
                  } else if (v == 'delete') {
                    _excluir(a);
                  } else if (v == 'refresh') {
                    // Atualiza apenas esta cotação
                    final preco = await _yahooService.obterCotacao(codigoYahoo);
                    if (preco != null && mounted) {
                      setState(() => _cotacoes[codigoYahoo] = preco);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Cotação atualizada: ${_currency.format(preco)}'),
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  }
                },
                itemBuilder: (ctx) => const [
                  PopupMenuItem(
                    value: 'refresh',
                    child: Row(children: [Icon(Icons.refresh, size: 18), SizedBox(width: 8), Text('Atualizar cotação')]),
                  ),
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
          colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: theme.colorScheme.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          const Icon(Icons.business, color: Colors.white),
          const SizedBox(width: 10),
          const Expanded(
            child: Text('Minhas Ações', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          if (_carregandoCotacoes)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
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
            colors: [theme.colorScheme.primary.withOpacity(0.08), theme.colorScheme.secondary.withOpacity(0.08)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: RefreshIndicator(
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
              final acoes = snap.data ?? [];
              if (acoes.isEmpty) {
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
                          Text('Nenhuma ação cadastrada', style: TextStyle(fontSize: 18, color: Colors.grey.shade700, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text('Toque em + para adicionar sua primeira ação', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600)),
                        ],
                      ),
                    ),
                  ],
                );
              }

              return ListView.builder(
                itemCount: acoes.length, // garanta que está usando .length
                itemBuilder: (ctx, i) {
                  if (i >= acoes.length) return const SizedBox.shrink(); // proteção extra
                  final acao = acoes[i];
                  return Card(
                    child: ListTile(
                      title: Text(acao.codigo),
                      subtitle: Text(acao.nomeEmpresa),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Atual: ${_currency.format(acao.precoAtual ?? 0)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Médio: ${_currency.format(acao.precoMedio ?? 0)}',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                          ),
                        ],
                      ),
                      onTap: () => _editarAcao(acao),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
      appBar: AppBar(
        title: const Text('Ações'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Recarregar cotações',
            onPressed: _recarregar,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final ok = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => const AcaoFormScreen()));
          if (ok == true) _recarregar();
        },
        icon: const Icon(Icons.add),
        label: const Text('Nova Ação'),
      ),
    );
  }
}
