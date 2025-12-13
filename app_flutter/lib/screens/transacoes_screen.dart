import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/transacao_service.dart';
import '../models/transacao.dart';
import 'transacao_form_screen.dart';
import '../services/acao_service.dart';
import '../models/acao.dart'; // adicione este import

class TransacoesScreen extends StatefulWidget {
  const TransacoesScreen({super.key});

  @override
  State<TransacoesScreen> createState() => _TransacoesScreenState();
}

class _TransacoesScreenState extends State<TransacoesScreen> {
  late Future<List<Transacao>> _futuro;
  final service = TransacaoService();
  final _acaoService = AcaoService();
  final _currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  final _date = DateFormat('dd/MM/yyyy');
  
  String _filtroTipo = 'todas';
  String _ordenacao = 'data_desc';

  @override
  void initState() {
    super.initState();
    _futuro = service.listarTransacoes();
  }

  Future<void> _recarregar() async {
    setState(() {
      _futuro = service.listarTransacoes();
    });
  }

  List<Transacao> _aplicarFiltros(List<Transacao> lista) {
    // Filtrar por tipo
    var filtrada = lista;
    if (_filtroTipo != 'todas') {
      filtrada = lista.where((t) => t.tipo.toLowerCase() == _filtroTipo).toList();
    }

    // Ordenar
    switch (_ordenacao) {
      case 'data_desc':
        filtrada.sort((a, b) => (b.dataTransacao ?? DateTime(1900)).compareTo(a.dataTransacao ?? DateTime(1900)));
        break;
      case 'data_asc':
        filtrada.sort((a, b) => (a.dataTransacao ?? DateTime(1900)).compareTo(b.dataTransacao ?? DateTime(1900)));
        break;
      case 'valor_desc':
        filtrada.sort((a, b) => (b.precoUnitario * b.quantidade).compareTo(a.precoUnitario * a.quantidade));
        break;
      case 'valor_asc':
        filtrada.sort((a, b) => (a.precoUnitario * a.quantidade).compareTo(b.precoUnitario * b.quantidade));
        break;
    }

    return filtrada;
  }

  Map<String, double> _calcularEstatisticas(List<Transacao> lista) {
    double totalCompras = 0;
    double totalVendas = 0;
    int countCompras = 0;
    int countVendas = 0;

    for (var t in lista) {
      final valor = t.precoUnitario * t.quantidade;
      if (t.tipo.toLowerCase() == 'compra') {
        totalCompras += valor;
        countCompras++;
      } else {
        totalVendas += valor;
        countVendas++;
      }
    }

    return {
      'totalCompras': totalCompras,
      'totalVendas': totalVendas,
      'saldo': totalVendas - totalCompras,
      'countCompras': countCompras.toDouble(),
      'countVendas': countVendas.toDouble(),
    };
  }

  Color _corTipo(Transacao t) => t.tipo.toLowerCase() == 'compra'
      ? Colors.green.shade600
      : Colors.red.shade600;

  Color _corOperacao(Transacao t) {
    if (t.tipoOperacao == 'CALL') return Colors.orange.shade700;
    if (t.tipoOperacao == 'PUT') return Colors.purple.shade700;
    return Colors.grey.shade600;
  }

  Future<void> _confirmarExclusao(Transacao t) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700),
            const SizedBox(width: 8),
            const Text('Excluir transação?'),
          ],
        ),
        content: Text('Confirma excluir ${t.tipo} de ${t.acaoCodigo ?? 'Ação ${t.acaoId}'}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await service.deletarTransacao(t.id!);
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Transação excluída com sucesso'),
            ],
          ),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
      await _recarregar(); // ADICIONE await
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text('Erro ao excluir: $e')),
            ],
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _chip(String label, {Color? color, IconData? icon}) {
    return Chip(
      label: Text(label),
      avatar: icon != null ? Icon(icon, size: 16, color: Colors.white) : null,
      backgroundColor: color ?? Colors.grey.shade200,
      labelStyle: TextStyle(
        color: color != null ? Colors.white : Colors.black87,
        fontSize: 11,
        fontWeight: FontWeight.w500,
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _precoChip(String codigo) {
    return FutureBuilder<Acao>(
      future: _acaoService.obterPreco(codigo),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Chip(label: Text('Carregando...'));
        }
        if (!snap.hasData || snap.data!.precoAtual == null) return const SizedBox.shrink();
        final preco = snap.data!.precoAtual!;
        final cor = Colors.blue;
        return Chip(
          label: Text('R\$ ${preco.toStringAsFixed(2)}'),
          backgroundColor: cor.withOpacity(0.15),
          labelStyle: TextStyle(color: cor.shade800, fontWeight: FontWeight.w600, fontSize: 11),
        );
      },
    );
  }

  Widget _estatisticasCard(Map<String, double> stats) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade700, Colors.blue.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade200,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Resumo Geral',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.analytics, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${stats['countCompras']!.toInt() + stats['countVendas']!.toInt()} ops',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _estatisticaItem(
                  Icons.arrow_downward,
                  'Compras',
                  _currency.format(stats['totalCompras']),
                  '${stats['countCompras']!.toInt()} ops',
                  Colors.green.shade300,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _estatisticaItem(
                  Icons.arrow_upward,
                  'Vendas',
                  _currency.format(stats['totalVendas']),
                  '${stats['countVendas']!.toInt()} ops',
                  Colors.red.shade300,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Saldo',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _currency.format(stats['saldo']),
                  style: TextStyle(
                    color: stats['saldo']! >= 0 ? Colors.greenAccent : Colors.redAccent,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _estatisticaItem(IconData icon, String label, String valor, String subtitulo, Color cor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: cor, size: 20),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            valor,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            subtitulo,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _filtrosBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _filtroChip('Todas', 'todas'),
                  const SizedBox(width: 8),
                  _filtroChip('Compras', 'compra', icon: Icons.arrow_downward, cor: Colors.green),
                  const SizedBox(width: 8),
                  _filtroChip('Vendas', 'venda', icon: Icons.arrow_upward, cor: Colors.red),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            tooltip: 'Ordenar',
            onSelected: (val) => setState(() => _ordenacao = val),
            itemBuilder: (ctx) => [
              PopupMenuItem(
                value: 'data_desc',
                child: Row(
                  children: [
                    Icon(Icons.arrow_downward, size: 18, color: Colors.grey.shade700),
                    const SizedBox(width: 8),
                    const Text('Mais recentes'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'data_asc',
                child: Row(
                  children: [
                    Icon(Icons.arrow_upward, size: 18, color: Colors.grey.shade700),
                    const SizedBox(width: 8),
                    const Text('Mais antigas'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'valor_desc',
                child: Row(
                  children: [
                    Icon(Icons.attach_money, size: 18, color: Colors.grey.shade700),
                    const SizedBox(width: 8),
                    const Text('Maior valor'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'valor_asc',
                child: Row(
                  children: [
                    Icon(Icons.money_off, size: 18, color: Colors.grey.shade700),
                    const SizedBox(width: 8),
                    const Text('Menor valor'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _filtroChip(String label, String valor, {IconData? icon, Color? cor}) {
    final selecionado = _filtroTipo == valor;
    return FilterChip(
      label: Text(label),
      avatar: icon != null ? Icon(icon, size: 16) : null,
      selected: selecionado,
      onSelected: (_) => setState(() => _filtroTipo = valor),
      selectedColor: cor?.withOpacity(0.2) ?? Colors.blue.shade100,
      checkmarkColor: cor ?? Colors.blue,
      backgroundColor: Colors.white,
      side: BorderSide(color: selecionado ? (cor ?? Colors.blue) : Colors.grey.shade300),
    );
  }

  Widget _card(Transacao t) {
    final total = t.precoUnitario * t.quantidade;
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          final ok = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => TransacaoFormScreen(transacao: t)),
          );
          if (ok == true) _recarregar();
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _corTipo(t).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(_corTipo(t) == Colors.green.shade600 ? Icons.arrow_downward : Icons.arrow_upward,
                        color: _corTipo(t), size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: _corTipo(t).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                t.tipo.toUpperCase(),
                                style: TextStyle(
                                  color: _corTipo(t),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                  letterSpacing: .5,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              t.acaoCodigo ?? 'Ação ${t.acaoId}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          t.dataTransacao != null ? _date.format(t.dataTransacao!) : 'Sem data',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (v) async {
                      if (v == 'edit') {
                        final ok = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(builder: (_) => TransacaoFormScreen(transacao: t)),
                        );
                        if (ok == true) _recarregar();
                      } else if (v == 'delete') {
                        _confirmarExclusao(t);
                      }
                    },
                    itemBuilder: (ctx) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 18),
                            SizedBox(width: 8),
                            Text('Editar'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 18, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Excluir', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _infoItem(
                      'Quantidade',
                      '${t.quantidade} un.',
                      Icons.numbers,
                      Colors.blue,
                    ),
                  ),
                  Expanded(
                    child: _infoItem(
                      'Preço Unit.',
                      _currency.format(t.precoUnitario),
                      Icons.attach_money,
                      Colors.orange,
                    ),
                  ),
                  Expanded(
                    child: _infoItem(
                      'Total',
                      _currency.format(total),
                      Icons.calculate,
                      Colors.purple,
                    ),
                  ),
                ],
              ),
              if (t.tipoOperacao != null || (t.nomeOpcao ?? '').isNotEmpty || t.dataExercicio != null) ...[
                const SizedBox(height: 16),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    if (t.tipoOperacao != null) _chip(t.tipoOperacao!, color: _corOperacao(t)),
                    if ((t.nomeOpcao ?? '').isNotEmpty) _chip(t.nomeOpcao!, icon: Icons.label),
                    if (t.dataExercicio != null)
                      _chip('Exerc: ${_date.format(t.dataExercicio!)}', icon: Icons.event),
                    if (t.valorStrike != null) _chip('Strike: ${_currency.format(t.valorStrike)}'),
                    if (t.porcentagemPremio != null)
                      _chip('Prêmio: ${t.porcentagemPremio!.toStringAsFixed(2)}%', color: Colors.teal),
                    if (t.exercidoOperacao == true)
                      _chip('Exercido', color: Colors.green.shade700, icon: Icons.check_circle),
                    if (t.corretoraOperada != null && t.corretoraOperada!.isNotEmpty)
                      _chip(t.corretoraOperada!, icon: Icons.business),
                    if (t.acaoCodigo != null) _precoChip(t.acaoCodigo!),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoItem(String label, String valor, IconData icon, Color cor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: cor),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          valor,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Transações'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Recarregar',
            onPressed: _recarregar,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary.withOpacity(0.08),
              theme.colorScheme.secondary.withOpacity(0.08),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: RefreshIndicator(
          onRefresh: _recarregar, // JÁ ESTÁ CORRETO (async)
          child: FutureBuilder<List<Transacao>>(
            future: _futuro,
            builder: (ctx, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Carregando transações...'),
                    ],
                  ),
                );
              }
              if (snap.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                        const SizedBox(height: 16),
                        Text(
                          'Erro ao carregar',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red.shade700),
                        ),
                        const SizedBox(height: 8),
                        Text('${snap.error}', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600)),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _recarregar,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Tentar novamente'),
                        ),
                      ],
                    ),
                  ),
                );
              }
              final todasTransacoes = snap.data ?? [];
              if (todasTransacoes.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.inbox, size: 80, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text(
                          'Nenhuma transação ainda',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Toque no botão + para adicionar sua primeira transação',
                          style: TextStyle(color: Colors.grey.shade600),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }
              
              final listaFiltrada = _aplicarFiltros(todasTransacoes);
              final stats = _calcularEstatisticas(todasTransacoes);

              return Column(
                children: [
                  _estatisticasCard(stats),
                  _filtrosBar(),
                  Expanded(
                    child: listaFiltrada.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.filter_alt_off, size: 64, color: Colors.grey.shade400),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Nenhuma transação com estes filtros',
                                    style: TextStyle(color: Colors.grey.shade600),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.only(bottom: 80, top: 8),
                            itemCount: listaFiltrada.length,
                            itemBuilder: (_, i) => _card(listaFiltrada[i]),
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final ok = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const TransacaoFormScreen()),
          );
          if (ok == true) await _recarregar(); // ADICIONE await
        },
        icon: const Icon(Icons.add),
        label: const Text('Nova Transação'),
      ),
    );
  }
}